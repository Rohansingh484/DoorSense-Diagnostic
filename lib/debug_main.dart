// // Copyright 2023, Charles Weinberger & Paul DeMarco.
// // All rights reserved. Use of this source code is governed by a
// // BSD-style license that can be found in the LICENSE file.
//
// import 'dart:async';
// import 'dart:io';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import 'widgets.dart';
//
// final snackBarKeyA = GlobalKey<ScaffoldMessengerState>();
// final snackBarKeyB = GlobalKey<ScaffoldMessengerState>();
// final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();
// final Map<DeviceIdentifier, ValueNotifier<bool>> isConnectingOrDisconnecting = {};
//
// void main() {
//   if (Platform.isAndroid) {
//     WidgetsFlutterBinding.ensureInitialized();
//     [
//       Permission.location,
//       Permission.storage,
//       Permission.bluetooth,
//       Permission.bluetoothConnect,
//       Permission.bluetoothScan
//     ].request().then((status) {
//       runApp(const FlutterBlueApp());
//     });
//   } else {
//     runApp(const FlutterBlueApp());
//   }
// }
//
// class BluetoothAdapterStateObserver extends NavigatorObserver {
//   StreamSubscription<BluetoothAdapterState>? _btStateSubscription;
//
//   @override
//   void didPush(Route route, Route? previousRoute) {
//     super.didPush(route, previousRoute);
//     if (route.settings.name == '/deviceScreen') {
//       // Start listening to Bluetooth state changes when a new route is pushed
//       _btStateSubscription ??= FlutterBluePlus.adapterState.listen((state) {
//         if (state != BluetoothAdapterState.on) {
//           // Pop the current route if Bluetooth is off
//           navigator?.pop();
//         }
//       });
//     }
//   }
//
//   @override
//   void didPop(Route route, Route? previousRoute) {
//     super.didPop(route, previousRoute);
//     // Cancel the subscription when the route is popped
//     _btStateSubscription?.cancel();
//     _btStateSubscription = null;
//   }
// }
//
// class FlutterBlueApp extends StatelessWidget {
//   const FlutterBlueApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       color: Colors.lightBlue,
//       home: StreamBuilder<BluetoothAdapterState>(
//           stream: FlutterBluePlus.adapterState,
//           initialData: BluetoothAdapterState.unknown,
//           builder: (c, snapshot) {
//             final adapterState = snapshot.data;
//             if (adapterState == BluetoothAdapterState.on) {
//               return const FindDevicesScreen();
//             } else {
//               FlutterBluePlus.stopScan();
//               return BluetoothOffScreen(adapterState: adapterState);
//             }
//           }),
//       navigatorObservers: [BluetoothAdapterStateObserver()],
//     );
//   }
// }
//
// class BluetoothOffScreen extends StatelessWidget {
//   const BluetoothOffScreen({Key? key, this.adapterState}) : super(key: key);
//
//   final BluetoothAdapterState? adapterState;
//
//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldMessenger(
//       key: snackBarKeyA,
//       child: Scaffold(
//         backgroundColor: Colors.lightBlue,
//         body: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               const Icon(
//                 Icons.bluetooth_disabled,
//                 size: 200.0,
//                 color: Colors.white54,
//               ),
//               Text(
//                 'Bluetooth Adapter is ${adapterState != null ? adapterState.toString().split(".").last : 'not available'}.',
//                 style: Theme.of(context).primaryTextTheme.titleSmall?.copyWith(color: Colors.white),
//               ),
//               if (Platform.isAndroid)
//                 ElevatedButton(
//                   child: const Text('TURN ON'),
//                   onPressed: () async {
//                     try {
//                       if (Platform.isAndroid) {
//                         await FlutterBluePlus.turnOn();
//                       }
//                     } catch (e) {
//                       final snackBar = snackBarFail(prettyException("Error Turning On:", e));
//                       snackBarKeyA.currentState?.removeCurrentSnackBar();
//                       snackBarKeyA.currentState?.showSnackBar(snackBar);
//                     }
//                   },
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
