import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothAdapterState bluetoothState = BluetoothAdapterState.unknown;

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        bluetoothState = state;
      });
    });
  }

  Future<void> scanDevice() async {
    // listen to scan results
    // Note: `onScanResults` only returns live scan results, i.e. during scanning. Use
    //  `scanResults` if you want live scan results *or* the results from a previous scan.
    var subscription = FlutterBluePlus.onScanResults.listen((results) {
            if (results.isNotEmpty) {
                ScanResult r = results.last; // the most recently found device
                print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
            }
        },
        onError: (e) => print(e),
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
      timeout: const Duration(seconds:15));

    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devicesList = results.map((r) => r.device).toList();
      });
      if (devicesList.isNotEmpty) {
        debugPrint("device found\n");
      } else {
        debugPrint("device not found\n");
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
  }

  void disconnectFromDevice() {
    connectedDevice?.disconnect();
    setState(() {
      connectedDevice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth App'),
        ),
        body: Column(
          children: <Widget>[
            Text('Bluetooth State: $bluetoothState'),
            ElevatedButton(
              onPressed: startScan/*scanDevice*/,
              child: const Text('Scan for Devices'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: devicesList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(devicesList[index].platformName),
                    subtitle: Text(devicesList[index].remoteId.toString()),
                    onTap: () => connectToDevice(devicesList[index]),
                  );
                },
              ),
            ),
            if (connectedDevice != null)
              Column(
                children: [
                  Text('Connected to ${connectedDevice?.platformName}'),
                  ElevatedButton(
                    onPressed: disconnectFromDevice,
                    child: const Text('Disconnect'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
