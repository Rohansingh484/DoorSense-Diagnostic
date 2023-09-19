import 'dart:math';
import 'dart:convert';

import 'package:doorsense_diagnostic/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io' show Platform;

import 'debug_main.dart';

enum StatusCheck { idle, loading, success, failure } //declare state check

final snackBarKeyA = GlobalKey<ScaffoldMessengerState>();
final snackBarKeyB = GlobalKey<ScaffoldMessengerState>();
final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();
final Map<DeviceIdentifier, ValueNotifier<bool>> isConnectingOrDisconnecting = {};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Home Screen'),
    );
  }
}

// work in my home page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StatusCheck stepOneStatus = StatusCheck.idle;
  StatusCheck stepTwoStatus = StatusCheck.idle;
  StatusCheck stepThreeStatus = StatusCheck.idle;
  StatusCheck stepFourStatus = StatusCheck.idle;
  StatusCheck stepFiveStatus = StatusCheck.idle;
  StatusCheck stepSixStatus = StatusCheck.idle;

  BluetoothDevice? doorSenseDevice;
  Set<DeviceIdentifier> seen = {};

  String deviceName = '';

  late Stream<List<int>> incomingDataStream;

  void startListening() async {
    // Discover services
    List<BluetoothService> services = await doorSenseDevice!.discoverServices();

    // Find the service and characteristic where you want to enable notifications
    for (BluetoothService service in services) {
      if (service.uuid == Guid('19B10000-E8F2-537E-4F6C-D104768A1214')) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid == Guid('19B10001-E8F2-537E-4F6C-D104768A1214')) {
            // Enable notifications for this characteristic
            //await characteristic.setNotifyValue(true);

            // Create a stream for incoming data
            incomingDataStream = characteristic.lastValueStream;

            // Start listening to the stream
            incomingDataStream.listen((List<int> value) {
              print("Received data: ${bytesToString(value)}");
              // Handle the incoming data here
            });
            break;
          }
        }
        break;
      }
    }
  }

Widget leadingIconState(StatusCheck status) {
    switch (status) {
      case StatusCheck.idle:
        return const Text("-", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),);
        case StatusCheck.loading:
        return const CircularProgressIndicator();
      case StatusCheck.success:
        return const Icon(
          Icons.check_box,
          color: Colors.green,
        );
      case StatusCheck.failure:
        return const Icon(
          Icons.highlight_off,
          color: Colors.red,
        );
      default:
        return const Text("-", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),);
    }
  }

  Future<void> initBluetooth() async {
    try {
      if (await FlutterBluePlus.isAvailable == false) {
        print("Bluetooth not supported by this device");
        return;
      }

// turn on bluetooth ourself if we can
// for iOS, the user controls bluetooth enable/disable
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }

// wait bluetooth to be on & print states
// note: for iOS the initial state is typically BluetoothAdapterState.unknown
// note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
      await FlutterBluePlus.adapterState
          .map((s) {
            print(s);
            return s;
          })
          .where((s) => s == BluetoothAdapterState.on)
          .first;
    } catch (e) {
      setState(() {
        stepOneStatus = StatusCheck.failure;
      });
    } finally {
      setState(() {
        stepOneStatus = StatusCheck.success;
      });
    }
  }

  Future<void> scanForBluetooth() async {
    // Note: You must call discoverServices after every connection!
    // Setup Listener for scan results.
// device not found? see "Common Problems" in the README
    Set<DeviceIdentifier> seen = {};
    var subscription = FlutterBluePlus.scanResults.listen(
            (results) {
          for (ScanResult r in results) {
            if (seen.contains(r.device.remoteId) == false) {
              print('${r.device.remoteId}: "${r.device.localName}" found! rssi: ${r.rssi}');
              seen.add(r.device.remoteId);
            }
          }
        },
    );

// Start scanning
// Note: You should always call `scanResults.listen` before you call startScan!
    await FlutterBluePlus.startScan();

  }

  String bytesToString(List<int> bytes) {
    // Decode the bytes using utf8 encoding
    String result = utf8.decode(bytes);
    return result;
  }

// can be edited
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: deviceName.isNotEmpty ? Colors.green : Colors.red,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
                leading: leadingIconState(stepOneStatus),
                title: const Text("Step 1: Init Bluetooth "),
                trailing: const Icon(Icons.arrow_forward_ios_outlined),
                onTap: () async {
                  await initBluetooth();
                }),
            ListTile(
              leading: leadingIconState(stepTwoStatus),
              title: const Text("Step 2: Connect to Bluetooth"),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
              onTap: () async {

    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Connect to Bluetooth'),
        content: Text(deviceName),
        actions: [
          TextButton(onPressed: () async {

            try {
              // Start scanning for devices
              FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

              // Listen for scanned devices
              FlutterBluePlus.scanResults.listen((scanResult) {
                for (var result in scanResult) {
                  if (result.device.localName == 'DoorSense') {
                    // Found the DoorSense device
                    doorSenseDevice = result.device;
                    print("DoorSense found!!!");
                    FlutterBluePlus.stopScan();
                    if (doorSenseDevice != null) {
                      setState(() {
                        deviceName = doorSenseDevice!.localName;
                      });
                      Navigator.of(context).pop();
                      print(doorSenseDevice!.localName);
                    }
                    break;
                  }
                }
              });
            } catch (e) {
              // Handle any errors that occur during the process
              print('Error: $e');
              setState((){
                stepTwoStatus = StatusCheck.failure;
              });
            }
          }, child: const Text("Find DoorSense Device")),
          TextButton(onPressed: () async {
            try {
              await doorSenseDevice!.connect();

              print("DoorSense successfully connected!!!");
            } catch (e) {
            // Handle any errors that occur during the process
            print('Error: $e');
            setState((){
            stepTwoStatus = StatusCheck.failure;
            });

            } finally {
              if (doorSenseDevice?.localName == "DoorSense") {
                setState(() {
                  stepTwoStatus = StatusCheck.success;
                });
                Navigator.of(context).pop();
              }
            }
          }, child: const Text("Connect")),
          TextButton(onPressed: () {
            Navigator.of(context).pop();
          }, child: const Text("Cancel"))
        ],
      );
    }
    );
              },
            ),
            ListTile(
              leading: leadingIconState(stepThreeStatus),
              title: const Text("Step 3: Register Fingerprint"),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
                onTap: () async {
                  // Show a loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Bluetooth Message'),
                        content: const CircularProgressIndicator(), // Add a loading indicator
                        actions: <Widget>[
                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: const Text("Cancel"))
                        ],
                      );
                    },
                  );
                  if (doorSenseDevice?.localName == 'DoorSense') {

                    print("Device found!");

                    // Discover services
                    List<BluetoothService> services = await doorSenseDevice!.discoverServices();
                    // Find the service and characteristic where you want to write the "READY!" value
                    for (BluetoothService service in services) {
                      // Replace with the UUID of your service
                      if (service.uuid == Guid('19B10000-E8F2-537E-4F6C-D104768A1214')) {
                        print(service.uuid);
                        for (BluetoothCharacteristic characteristic in service.characteristics) {
                          // Replace with the UUID of your characteristic
                          if (characteristic.uuid == Guid('19B10001-E8F2-537E-4F6C-D104768A1214')) {
                            print(characteristic.uuid);
                            //write a 1 to the board to indicate that the user is ready to register fingerprint
                            await characteristic.write([0x1]);
                            print("Write successful!");
                            break;
                          }
                        }
                        break;
                      }
                    }

                    // Disconnect from the device
                    // await r.device.disconnect();

                    // Close the loading dialog
                    Navigator.of(context).pop();

                    String test = 'Start registration';
                    // Show a success dialog or navigate to the next step
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Waiting...'),
                          content: const Text('Preparing to register fingerprint'),
                          actions: <Widget>[
                            TextButton(
                              child: Text(test),
                              onPressed: () async {
                                // // Discover services
                                List<BluetoothService> services = await doorSenseDevice!.discoverServices();
                                // Find the service and characteristic where you want to write the "READY!" value
                                for (BluetoothService service in services) {
                                  // Replace with the UUID of your service
                                  if (service.uuid == Guid(
                                      '19B10000-E8F2-537E-4F6C-D104768A1214')) {
                                    print(service.uuid);
                                    for (BluetoothCharacteristic characteristic in service
                                        .characteristics) {
                                      // Replace with the UUID of your characteristic
                                      if (characteristic.uuid == Guid(
                                          '19B10001-E8F2-537E-4F6C-D104768A1214')) {
                                        // List<int> value = await characteristic
                                        //     .read();
                                        // print(bytesToString(value));
                                        // Create a stream for incoming data
                                        incomingDataStream = characteristic.lastValueStream;

                                        // Start listening to the stream
                                        incomingDataStream.listen((List<int> value) {
                                          print("Received data: ${bytesToString(value)}");
                                          // Handle the incoming data here
                                        });
                                        break;
                                      }
                                    }
                                    break;
                                  }
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
            ),
            ListTile(
              leading: leadingIconState(stepFourStatus),
              title: const Text("Step 4: Show Registered Fingerprint Hash"),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: leadingIconState(stepFiveStatus),
              title: const Text("Step 5: Store Hash in Database"),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              leading: leadingIconState(stepSixStatus),
              title: const Text("Step 6: Unlock Actuator"),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
          ],
        ),
      ),
    );
  }
}