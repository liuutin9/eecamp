import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothAdapterState bluetoothState = BluetoothAdapterState.unknown;
  BluetoothCharacteristic? characteristic;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        bluetoothState = state;
      });
    });
  }

  Future<void> checkPermissions() async {
    var locationPermission = await Permission.location.request();
    var bluetoothPermission = await Permission.bluetoothScan.request();

    if (locationPermission.isGranted && bluetoothPermission.isGranted) {
      startScan();
    } else if (!locationPermission.isGranted) {
      locationPermission = await Permission.location.request();
    } else if (!bluetoothPermission.isGranted) {
      bluetoothPermission = await Permission.bluetoothScan.request();
    } else {
      debugPrint("Permissions not granted\n");
    }
  }

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devicesList = results.map((r) => r.device).toList();
      });
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
    discoverServices(device);
    await FlutterBluePlus.stopScan();
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      debugPrint('Service found: ${service.uuid}');
      for (var char in service.characteristics) {
        debugPrint('Characteristic found: ${char.uuid}');
        if (char.properties.write && char.properties.read) {
          setState(() {
            characteristic = char;
          });
          break;
        }
      }
    }
    if (characteristic == null) {
      debugPrint('No writable and readable characteristic found');
    }
  }

  void disconnectFromDevice() {
    connectedDevice?.disconnect();
    setState(() {
      connectedDevice = null;
      characteristic = null;
    });
  }

  void sendMessage(String message) async {
    if (characteristic != null) {
      await characteristic!.write(message.codeUnits, withoutResponse: true);
    }
  }

  void receiveMessage() async {
    if (characteristic != null) {
      var value = await characteristic!.read();
      String receivedMessage = String.fromCharCodes(value);
      debugPrint('Received: $receivedMessage');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Received Message'),
          content: Text(receivedMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
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
              onPressed: checkPermissions,
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
              Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text('Connected to ${connectedDevice?.platformName}'),
                      ElevatedButton(
                        onPressed: disconnectFromDevice,
                        child: const Text('Disconnect'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              decoration: const InputDecoration(
                                labelText: 'Send Message',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              sendMessage(messageController.text);
                              messageController.clear();
                            },
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: receiveMessage,
                        child: const Text('Receive Message'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
