import 'dart:math';

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

  void findDeviceScreen() {
    try {
      showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25.0),
            ),
          ),
          builder: (context) {
            return const SizedBox(
                height: 450,
                child: FindDevicesScreen());
          }
      );
    } catch(e){
      setState(() {
        stepTwoStatus = StatusCheck.failure;
      });
    } finally {
    }
  }

// can be edited
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                findDeviceScreen();
              },
            ),
            ListTile(
              leading: leadingIconState(stepThreeStatus),
              title: const Text("Step 3: Register Fingerprint"),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
              onTap: () async {
                // Reads all characteristics

                showDialog(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Bluetooth Message'),
                        content: const SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text(''),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Approve'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
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

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find Devices'),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            setState(() {}); // force refresh of connectedSystemDevices
            if (FlutterBluePlus.isScanningNow == false) {
              FlutterBluePlus.startScan(timeout: const Duration(seconds: 15), androidUsesFineLocation: false);
            }
            return Future.delayed(Duration(milliseconds: 500)); // show refresh icon breifly
          },
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.fromFuture(FlutterBluePlus.connectedSystemDevices),
                  initialData: const [],
                  builder: (c, snapshot) => Column(
                    children: (snapshot.data ?? [])
                        .map((d) => ListTile(
                      title: Text(d.localName),
                      subtitle: Text(d.remoteId.toString()),
                      trailing: StreamBuilder<BluetoothConnectionState>(
                        stream: d.connectionState,
                        initialData: BluetoothConnectionState.disconnected,
                        builder: (c, snapshot) {
                          if (snapshot.data == BluetoothConnectionState.connected) {
                            return ElevatedButton(
                              child: const Text('OPEN'),
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DeviceScreen(device: d),
                                  settings: RouteSettings(name: '/deviceScreen'))),
                            );
                          }
                          if (snapshot.data == BluetoothConnectionState.disconnected) {
                            return ElevatedButton(
                                child: const Text('CONNECT'),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) {
                                        isConnectingOrDisconnecting[d.remoteId] ??= ValueNotifier(true);
                                        isConnectingOrDisconnecting[d.remoteId]!.value = true;
                                        d.connect(timeout: Duration(seconds: 35)).catchError((e) {
                                          final snackBar = snackBarFail(prettyException("Connect Error:", e));
                                          snackBarKeyC.currentState?.removeCurrentSnackBar();
                                          snackBarKeyC.currentState?.showSnackBar(snackBar);
                                        }).then((v) {
                                          isConnectingOrDisconnecting[d.remoteId] ??= ValueNotifier(false);
                                          isConnectingOrDisconnecting[d.remoteId]!.value = false;
                                        });
                                        return DeviceScreen(device: d);
                                      },
                                      settings: RouteSettings(name: '/deviceScreen')));
                                });
                          }
                          return Text(snapshot.data.toString().toUpperCase().split('.')[1]);
                        },
                      ),
                    ))
                        .toList(),
                  ),
                ),
                StreamBuilder<List<ScanResult>>(
                  stream: FlutterBluePlus.scanResults,
                  initialData: const [],
                  builder: (c, snapshot) => Column(
                    children: (snapshot.data ?? [])
                        .map(
                          (r) => ScanResultTile(
                        result: r,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              isConnectingOrDisconnecting[r.device.remoteId] ??= ValueNotifier(true);
                              isConnectingOrDisconnecting[r.device.remoteId]!.value = true;
                              r.device.connect(timeout: Duration(seconds: 35)).catchError((e) {
                                final snackBar = snackBarFail(prettyException("Connect Error:", e));
                                snackBarKeyC.currentState?.removeCurrentSnackBar();
                                snackBarKeyC.currentState?.showSnackBar(snackBar);
                              }).then((v) {
                                isConnectingOrDisconnecting[r.device.remoteId] ??= ValueNotifier(false);
                                isConnectingOrDisconnecting[r.device.remoteId]!.value = false;
                              });
                              return DeviceScreen(device: r.device);
                            },
                            settings: RouteSettings(name: '/deviceScreen'))),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBluePlus.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data ?? false) {
              return FloatingActionButton(
                child: const Icon(Icons.stop),
                onPressed: () async {
                  try {
                    FlutterBluePlus.stopScan();
                  } catch (e) {
                    final snackBar = snackBarFail(prettyException("Stop Scan Error:", e));
                    snackBarKeyB.currentState?.removeCurrentSnackBar();
                    snackBarKeyB.currentState?.showSnackBar(snackBar);
                  }
                },
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                  child: const Text("SCAN"),
                  onPressed: () async {
                    try {
                      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15), androidUsesFineLocation: false);
                    } catch (e) {
                      final snackBar = snackBarFail(prettyException("Start Scan Error:", e));
                      snackBarKeyB.currentState?.removeCurrentSnackBar();
                      snackBarKeyB.currentState?.showSnackBar(snackBar);
                    }
                    setState(() {}); // force refresh of connectedSystemDevices
                  });
            }
          },
        ),
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  List<int> _getRandomBytes() {
    final math = Random();
    return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
  }

  List<Widget> _buildServiceTiles(BuildContext context, List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
        service: s,
        characteristicTiles: s.characteristics
            .map(
              (c) => CharacteristicTile(
            characteristic: c,
            onReadPressed: () async {
              try {
                await c.read();
                final snackBar = snackBarGood("Read: Success");
                snackBarKeyC.currentState?.removeCurrentSnackBar();
                snackBarKeyC.currentState?.showSnackBar(snackBar);
              } catch (e) {
                final snackBar = snackBarFail(prettyException("Read Error:", e));
                snackBarKeyC.currentState?.removeCurrentSnackBar();
                snackBarKeyC.currentState?.showSnackBar(snackBar);
              }
            },
            onWritePressed: () async {
              try {
                await c.write(_getRandomBytes(), withoutResponse: c.properties.writeWithoutResponse);
                final snackBar = snackBarGood("Write: Success");
                snackBarKeyC.currentState?.removeCurrentSnackBar();
                snackBarKeyC.currentState?.showSnackBar(snackBar);
                if (c.properties.read) {
                  await c.read();
                }
              } catch (e) {
                final snackBar = snackBarFail(prettyException("Write Error:", e));
                snackBarKeyC.currentState?.removeCurrentSnackBar();
                snackBarKeyC.currentState?.showSnackBar(snackBar);
              }
            },
            onNotificationPressed: () async {
              try {
                String op = c.isNotifying == false ? "Subscribe" : "Unsubscribe";
                await c.setNotifyValue(c.isNotifying == false);
                final snackBar = snackBarGood("$op : Success");
                snackBarKeyC.currentState?.removeCurrentSnackBar();
                snackBarKeyC.currentState?.showSnackBar(snackBar);
                if (c.properties.read) {
                  await c.read();
                }
              } catch (e) {
                final snackBar = snackBarFail(prettyException("Subscribe Error:", e));
                snackBarKeyC.currentState?.removeCurrentSnackBar();
                snackBarKeyC.currentState?.showSnackBar(snackBar);
              }
            },
            descriptorTiles: c.descriptors
                .map(
                  (d) => DescriptorTile(
                descriptor: d,
                onReadPressed: () async {
                  try {
                    await d.read();
                    final snackBar = snackBarGood("Read: Success");
                    snackBarKeyC.currentState?.removeCurrentSnackBar();
                    snackBarKeyC.currentState?.showSnackBar(snackBar);
                  } catch (e) {
                    final snackBar = snackBarFail(prettyException("Read Error:", e));
                    snackBarKeyC.currentState?.removeCurrentSnackBar();
                    snackBarKeyC.currentState?.showSnackBar(snackBar);
                  }
                },
                onWritePressed: () async {
                  try {
                    await d.write(_getRandomBytes());
                    final snackBar = snackBarGood("Write: Success");
                    snackBarKeyC.currentState?.removeCurrentSnackBar();
                    snackBarKeyC.currentState?.showSnackBar(snackBar);
                  } catch (e) {
                    final snackBar = snackBarFail(prettyException("Write Error:", e));
                    snackBarKeyC.currentState?.removeCurrentSnackBar();
                    snackBarKeyC.currentState?.showSnackBar(snackBar);
                  }
                },
              ),
            )
                .toList(),
          ),
        )
            .toList(),
      ),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: snackBarKeyC,
      child: Scaffold(
        appBar: AppBar(
          title: Text(device.localName),
          actions: <Widget>[
            StreamBuilder<BluetoothConnectionState>(
              stream: device.connectionState,
              initialData: BluetoothConnectionState.connecting,
              builder: (c, snapshot) {
                VoidCallback? onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothConnectionState.connected:
                    onPressed = () async {
                      isConnectingOrDisconnecting[device.remoteId] ??= ValueNotifier(true);
                      isConnectingOrDisconnecting[device.remoteId]!.value = true;
                      try {
                        await device.disconnect();
                        final snackBar = snackBarGood("Disconnect: Success");
                        snackBarKeyC.currentState?.removeCurrentSnackBar();
                        snackBarKeyC.currentState?.showSnackBar(snackBar);
                      } catch (e) {
                        final snackBar = snackBarFail(prettyException("Disconnect Error:", e));
                        snackBarKeyC.currentState?.removeCurrentSnackBar();
                        snackBarKeyC.currentState?.showSnackBar(snackBar);
                      }
                      isConnectingOrDisconnecting[device.remoteId] ??= ValueNotifier(false);
                      isConnectingOrDisconnecting[device.remoteId]!.value = false;
                    };
                    text = 'DISCONNECT';
                    break;
                  case BluetoothConnectionState.disconnected:
                    onPressed = () async {
                      isConnectingOrDisconnecting[device.remoteId] ??= ValueNotifier(true);
                      isConnectingOrDisconnecting[device.remoteId]!.value = true;
                      try {
                        await device.connect(timeout: Duration(seconds: 35));
                        final snackBar = snackBarGood("Connect: Success");
                        snackBarKeyC.currentState?.removeCurrentSnackBar();
                        snackBarKeyC.currentState?.showSnackBar(snackBar);
                      } catch (e) {
                        final snackBar = snackBarFail(prettyException("Connect Error:", e));
                        snackBarKeyC.currentState?.removeCurrentSnackBar();
                        snackBarKeyC.currentState?.showSnackBar(snackBar);
                      }
                      isConnectingOrDisconnecting[device.remoteId] ??= ValueNotifier(false);
                      isConnectingOrDisconnecting[device.remoteId]!.value = false;
                    };
                    text = 'CONNECT';
                    break;
                  default:
                    onPressed = null;
                    text = snapshot.data.toString().split(".").last.toUpperCase();
                    break;
                }
                return ValueListenableBuilder<bool>(
                    valueListenable: isConnectingOrDisconnecting[device.remoteId]!,
                    builder: (context, value, child) {
                      isConnectingOrDisconnecting[device.remoteId] ??= ValueNotifier(false);
                      if (isConnectingOrDisconnecting[device.remoteId]!.value == true) {
                        // Show spinner when connecting or disconnecting
                        return Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.black12,
                              color: Colors.black26,
                            ),
                          ),
                        );
                      } else {
                        return TextButton(
                            onPressed: onPressed,
                            child: Text(
                              text,
                              style: Theme.of(context).primaryTextTheme.labelLarge?.copyWith(color: Colors.white),
                            ));
                      }
                    });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<BluetoothConnectionState>(
                stream: device.connectionState,
                initialData: BluetoothConnectionState.connecting,
                builder: (c, snapshot) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${device.remoteId}'),
                    ),
                    ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          snapshot.data == BluetoothConnectionState.connected
                              ? const Icon(Icons.bluetooth_connected)
                              : const Icon(Icons.bluetooth_disabled),
                          snapshot.data == BluetoothConnectionState.connected
                              ? StreamBuilder<int>(
                              stream: rssiStream(maxItems: 1),
                              builder: (context, snapshot) {
                                return Text(snapshot.hasData ? '${snapshot.data}dBm' : '',
                                    style: Theme.of(context).textTheme.bodySmall);
                              })
                              : Text('', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      title: Text('Device is ${snapshot.data.toString().split('.')[1]}.'),
                      trailing: StreamBuilder<bool>(
                        stream: device.isDiscoveringServices,
                        initialData: false,
                        builder: (c, snapshot) => IndexedStack(
                          index: (snapshot.data ?? false) ? 1 : 0,
                          children: <Widget>[
                            TextButton(
                              child: const Text("Get Services"),
                              onPressed: () async {
                                try {
                                  await device.discoverServices();
                                  final snackBar = snackBarGood("Discover Services: Success");
                                  snackBarKeyC.currentState?.removeCurrentSnackBar();
                                  snackBarKeyC.currentState?.showSnackBar(snackBar);
                                } catch (e) {
                                  final snackBar = snackBarFail(prettyException("Discover Services Error:", e));
                                  snackBarKeyC.currentState?.removeCurrentSnackBar();
                                  snackBarKeyC.currentState?.showSnackBar(snackBar);
                                }
                              },
                            ),
                            const IconButton(
                              icon: SizedBox(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.grey),
                                ),
                                width: 18.0,
                                height: 18.0,
                              ),
                              onPressed: null,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<int>(
                stream: device.mtu,
                initialData: 0,
                builder: (c, snapshot) => ListTile(
                  title: const Text('MTU Size'),
                  subtitle: Text('${snapshot.data} bytes'),
                  trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        try {
                          await device.requestMtu(223);
                          final snackBar = snackBarGood("Request Mtu: Success");
                          snackBarKeyC.currentState?.removeCurrentSnackBar();
                          snackBarKeyC.currentState?.showSnackBar(snackBar);
                        } catch (e) {
                          final snackBar = snackBarFail(prettyException("Change Mtu Error:", e));
                          snackBarKeyC.currentState?.removeCurrentSnackBar();
                          snackBarKeyC.currentState?.showSnackBar(snackBar);
                        }
                      }),
                ),
              ),
              StreamBuilder<List<BluetoothService>>(
                stream: device.servicesStream,
                initialData: const [],
                builder: (c, snapshot) {
                  return Column(
                    children: _buildServiceTiles(context, snapshot.data ?? []),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<int> rssiStream({Duration frequency = const Duration(seconds: 5), int? maxItems = null}) async* {
    var isConnected = true;
    final subscription = device.connectionState.listen((v) {
      isConnected = v == BluetoothConnectionState.connected;
    });
    int i = 0;
    while (isConnected && (maxItems == null || i < maxItems)) {
      try {
        yield await device.readRssi();
      } catch (e) {
        print("Error reading RSSI: $e");
        break;
      }
      await Future.delayed(frequency);
      i++;
    }
    // Device disconnected, stopping RSSI stream
    subscription.cancel();
  }
}

String prettyException(String prefix, dynamic e) {
  if (e is FlutterBluePlusException) {
    return "$prefix ${e.description}";
  } else if (e is PlatformException) {
    return "$prefix ${e.message}";
  }
  return prefix + e.toString();
}