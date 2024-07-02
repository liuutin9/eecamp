import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectionPage extends StatefulWidget {
  
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(5.0),
          child: Text(
            "Connection Page",
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // first, check if bluetooth is supported by your hardware
            // Note: The platform is initialized on the first call to any FlutterBluePlus method.
            if (await FlutterBluePlus.isSupported == false) {
                debugPrint("Bluetooth not supported by this device");
                return;
            }

            // handle bluetooth on & off
            // note: for iOS the initial state is typically BluetoothAdapterState.unknown
            // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
            var subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) async {
                debugPrint(state.toString());
                debugPrint("kkk\n");
                if (state == BluetoothAdapterState.on) {
                  // usually start scanning, connecting, etc
                  // listen to scan results
                  // Note: `onScanResults` only returns live scan results, i.e. during scanning. Use
                  //  `scanResults` if you want live scan results *or* the results from a previous scan.
                  var subscription = FlutterBluePlus.scanResults.listen((results) {
                      if (results.isNotEmpty) {
                        ScanResult r = results.last; // the most recently found device
                        debugPrint('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
                      }
                      else {
                        debugPrint("No device");
                      }
                    },
                    onError: (e) => debugPrint(e),
                  );

                  // cleanup: cancel subscription when scanning stops
                  FlutterBluePlus.cancelWhenScanComplete(subscription);

                  // Wait for Bluetooth enabled & permission granted
                  // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
                  await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;

                  // Start scanning w/ timeout
                  // Optional: use `stopScan()` as an alternative to timeout
                  await FlutterBluePlus.startScan(
                    withServices:[Guid("180D")], // match any of the specified services
                    withNames:["Bluno"], // *or* any of the specified names
                    timeout: const Duration(seconds: 10));

                  // wait for scanning to stop
                  await FlutterBluePlus.isScanning.where((val) => val == false).first;
                } else {
                    // show an error to the user, etc
                    debugPrint("BluetoothAdapterState failed");
                }
            });

            // turn on bluetooth ourself if we can
            // for iOS, the user controls bluetooth enable/disable
            if (Platform.isAndroid) {
                await FlutterBluePlus.turnOn();
            }

            // cancel to prevent duplicate listeners
            subscription.cancel();
          },
          child: const Text("Search device"),
        ),
      ),
    );
  }
}