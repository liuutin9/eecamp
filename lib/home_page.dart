import 'package:eecamp/services/bluetooth_service.dart';
import 'package:eecamp/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.context});
  final BuildContext context;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<BluetoothDevice> devicesList = [];
  StreamSubscription? scanSubscription;
  bool isScanning = false; // Track scanning state
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart,
    ));
    checkPermissions();
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    _controller.dispose();
    super.dispose();
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
    setState(() {
      isScanning = true; // Set scanning state to true
    });

    _controller.repeat();

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          devicesList = results.map((r) => r.device).toList();
        });
      }
    });

    // Wait for the scan to complete before setting the state to false
    await Future.delayed(const Duration(seconds: 15));
    if (mounted) {
      setState(() {
        isScanning = false; // Set scanning state to false
      });
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'EECamp Car Controller',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        actions: [
          RotationTransition(
            turns: _animation,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: isScanning ? null : checkPermissions,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesList[index].platformName == '' ? 'Unknown' : devicesList[index].platformName),
                  subtitle: Text(devicesList[index].remoteId.toString()),
                  onTap: () {
                    Provider.of<BluetoothProvider>(context, listen: false)
                        .setSelectedDevice(devicesList[index]);
                    Provider.of<NavigationService>(context, listen: false)
                        .goControlPanel(deviceId: devicesList[index].remoteId.toString());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
