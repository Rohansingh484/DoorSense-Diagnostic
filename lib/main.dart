import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io' show Platform;

enum StatusCheck { idle, loading, success, failure } //declare state check

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
            ),
            ListTile(
              leading: leadingIconState(stepThreeStatus),
              title: const Text("Step 3: Register Fingerprint"),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
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
