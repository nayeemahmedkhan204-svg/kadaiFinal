import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import '../core/printer/bluetooth_printer_manager.dart';

class PrinterProvider extends ChangeNotifier {
  final BluetoothPrinterManager _manager = BluetoothPrinterManager();

  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _statusMessage;

  List<BluetoothDevice> get devices => _devices;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _manager.isConnected;
  BluetoothDevice? get connectedDevice => _manager.connectedDevice;
  int get paperSize => _manager.paperSize;
  String? get statusMessage => _statusMessage;

  Future<void> init() async {
    await _manager.init();
    await scanDevices();
  }

  Future<void> scanDevices() async {
    _isScanning = true;
    _statusMessage = null;
    notifyListeners();

    _devices = await _manager.getPairedDevices();
    _isScanning = false;
    notifyListeners();
  }

  Future<bool> connect(BluetoothDevice device) async {
    _isConnecting = true;
    _statusMessage = 'Connecting to ${device.name}...';
    notifyListeners();

    final success = await _manager.connect(device);
    _isConnecting = false;
    _statusMessage = success ? 'Connected successfully.' : 'Failed to connect.';
    notifyListeners();
    return success;
  }

  Future<void> disconnect() async {
    await _manager.disconnect();
    _statusMessage = 'Disconnected.';
    notifyListeners();
  }

  Future<void> setPaperSize(int size) async {
    await _manager.setPaperSize(size);
    notifyListeners();
  }

  Future<bool> printBill(Map<String, dynamic> printData) async {
    if (!isConnected) {
      _statusMessage = 'Printer not connected. Please connect printer.';
      notifyListeners();
      return false;
    }
    return await _manager.printReceipt(printData);
  }
}
