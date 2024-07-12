import 'package:eecamp/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class BluetoothProvider extends ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;
  BluetoothDevice? _selectedDevice;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  BluetoothCharacteristic? get characteristic => _characteristic;
  BluetoothDevice? get selectedDevice => _selectedDevice;

  bool isDisconnected() {
    return _connectedDevice == null ? true : _connectedDevice!.isDisconnected;
  }

  void setSelectedDevice(BluetoothDevice? device) {
    _selectedDevice = device;
    notifyListeners();
  }

  void setConnectedDevice(BluetoothDevice? device) {
    _connectedDevice = device;
    notifyListeners();
  }

  void setCharacteristic(BluetoothCharacteristic? characteristic) {
    _characteristic = characteristic;
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice device, BuildContext context) async {
    try {
      FlutterBluePlus.stopScan();
      await device.connect().timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('Connection timeout');
        return Future.error('Connection timeout');
      });

      setConnectedDevice(device);
      bool servicesDiscovered = await discoverServices(device);

      if (servicesDiscovered) {
        notifyListeners();
      } else {
        throw Exception('No writable and readable characteristic found');
      }
    } catch (e) {
      debugPrint('Failed to connect to device: $e');
      if (context.mounted) {
        Provider.of<NavigationService>(context, listen: false).goHome();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to device: $e')),
        );
      }
    }
  }

  Future<bool> discoverServices(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      var service = services.where((sv) => sv.uuid == Guid.fromString('ffe0')).first;
      var char = service.characteristics.where((ch) => ch.uuid == Guid.fromString('ffe1')).first;
      setCharacteristic(char);
      return true;
    } catch (e) {
      debugPrint('Failed to discover services: $e');
      return false;
    }
  }

  Future<void> disconnectFromDevice() async {
    await _connectedDevice?.disconnect();
    setConnectedDevice(null);
    setCharacteristic(null);
    setSelectedDevice(null);
    notifyListeners();
  }
}
