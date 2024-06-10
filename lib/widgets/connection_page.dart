import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:home_widget/home_widget.dart';

class ConnectionPage extends StatefulWidget {
  
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {

  static const flutterChannel = MethodChannel("com.eecamp.app/flutter");
  String batteryLevel = "Unknown";

  Future getbatteryLevel() async {
    final int currentBatteryLevel =
        await flutterChannel.invokeMethod("getBatteryLevel");
    setState(() {
      batteryLevel = "$currentBatteryLevel%";
    });
  }

  Future openCamera() async {
    await flutterChannel.invokeMethod("openCamera");
  }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Battery Level: $batteryLevel",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 18),
                foregroundColor: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple
                ).onPrimary,
                backgroundColor: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple
                ).primary,
              ),
              onPressed: getbatteryLevel,
              child: const Text(
                "Get Battery Level",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 18),
                foregroundColor: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple
                ).onPrimary,
                backgroundColor: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple
                ).primary,
              ),
              onPressed: openCamera,
              child: const Text(
                "Open Camera",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}