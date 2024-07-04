import 'package:eecamp/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eecamp/services/bluetooth_service.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  TextEditingController messageController = TextEditingController();

  Future<void> sendMessage(String message, BluetoothProvider bluetooth) async {
    if (bluetooth.connectedDevice!.isConnected) debugPrint("Yes");
    if (bluetooth.characteristic!.properties.write) debugPrint("true");
    if (bluetooth.characteristic != null) {
      try {
        await bluetooth.characteristic!.write(message.codeUnits, withoutResponse: true);
      } catch (e) {
        debugPrint('Error sending message: $e');
      }
    }
  }

  void receiveMessage(BluetoothProvider bluetooth) async {
    if (bluetooth.characteristic != null) {
      try {
        var value = await bluetooth.characteristic!.read();
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
      } catch (e) {
        debugPrint('Error receiving message: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    BluetoothProvider bluetooth = Provider.of<BluetoothProvider>(context, listen: false);
    return FutureBuilder(
      future: bluetooth.connectToDevice(bluetooth.selectedDevice!, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('Connecting to ${bluetooth.selectedDevice?.platformName}'),
                ],
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Failed to connect: ${snapshot.error}'),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  bluetooth.disconnectFromDevice(context);
                  Provider.of<NavigationService>(context, listen: false).goHome();
                },
              ),
              title: Text(bluetooth.selectedDevice?.platformName ?? 'Device'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Connected to ${bluetooth.connectedDevice?.platformName}'),
                    ElevatedButton(
                      onPressed: () {
                        bluetooth.disconnectFromDevice(context);
                        Provider.of<NavigationService>(context, listen: false).goHome();
                      },
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
                          onPressed: () async {
                            await sendMessage(messageController.text, bluetooth);
                            messageController.clear();
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => receiveMessage(bluetooth),
                      child: const Text('Receive Message'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
