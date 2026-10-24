import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class BluetoothPrinterManager {
  static final BluetoothPrinterManager _instance = BluetoothPrinterManager._internal();
  factory BluetoothPrinterManager() => _instance;
  BluetoothPrinterManager._internal();

  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  int _paperSize = 58; // 58 or 80 mm

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _isConnected;
  int get paperSize => _paperSize;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _paperSize = prefs.getInt(AppConstants.keyPrinterPaperSize) ?? 58;
    _isConnected = await _bluetooth.isConnected ?? false;
  }

  Future<void> setPaperSize(int size) async {
    _paperSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyPrinterPaperSize, size);
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      final devices = await _bluetooth.getBondedDevices();
      return devices;
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      if (_isConnected) {
        await _bluetooth.disconnect();
      }
      await _bluetooth.connect(device);
      _connectedDevice = device;
      _isConnected = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyPrinterAddress, device.address ?? '');
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
      _isConnected = false;
      _connectedDevice = null;
    } catch (_) {}
  }

  Future<bool> printReceipt(Map<String, dynamic> printData) async {
    if (!_isConnected) {
      return false;
    }

    try {
      final header = printData['store_header'] as Map<String, dynamic>? ?? {};
      final meta = printData['invoice_meta'] as Map<String, dynamic>? ?? {};
      final items = printData['items'] as List<dynamic>? ?? [];
      final summary = printData['summary'] as Map<String, dynamic>? ?? {};
      final qr = printData['upi_qr_payload'] as String?;
      final footer = printData['footer'] as String? ?? 'Thank you! Visit again.';

      final int width = _paperSize == 80 ? 48 : 32;

      _bluetooth.printNewLine();

      // Store Header
      _bluetooth.printCustom(header['name'] ?? 'KadaiKhata Store', 2, 1);
      if (header['address'] != null && header['address'].toString().isNotEmpty) {
        _bluetooth.printCustom(header['address'].toString(), 0, 1);
      }
      if (header['phone'] != null && header['phone'].toString().isNotEmpty) {
        _bluetooth.printCustom("Ph: ${header['phone']}", 0, 1);
      }
      if (header['gstin'] != null && header['gstin'].toString().isNotEmpty) {
        _bluetooth.printCustom("GSTIN: ${header['gstin']}", 0, 1);
      }

      _bluetooth.printCustom("-" * width, 0, 1);

      // Invoice Details
      _bluetooth.printLeftRight("Bill: ${meta['invoice_number']}", "Date: ${meta['invoice_date']}", 0);
      if (meta['customer_name'] != null && meta['customer_name'] != 'Walk-in Customer') {
        _bluetooth.printCustom("Customer: ${meta['customer_name']}", 0, 0);
      }
      _bluetooth.printLeftRight("Mode: ${meta['payment_method']}", "Status: ${meta['payment_status']}", 0);

      _bluetooth.printCustom("-" * width, 0, 1);

      // Line Items Header
      if (_paperSize == 80) {
        _bluetooth.printCustom("ITEM                  QTY   RATE    TOTAL", 1, 0);
      } else {
        _bluetooth.printCustom("ITEM             QTY  RATE  TOTAL", 0, 0);
      }

      _bluetooth.printCustom("-" * width, 0, 1);

      // Items
      for (var item in items) {
        final name = item['name']?.toString() ?? '';
        final qty = (item['qty'] as num?)?.toDouble() ?? 1.0;
        final unit = item['unit'] ?? 'PCS';
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final total = (item['total'] as num?)?.toDouble() ?? 0.0;

        _bluetooth.printCustom(name, 0, 0);
        final lineDetails = " ${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2)} $unit x Rs.${price.toStringAsFixed(2)}";
        final lineTotal = "Rs.${total.toStringAsFixed(2)}";
        _bluetooth.printLeftRight(lineDetails, lineTotal, 0);
      }

      _bluetooth.printCustom("-" * width, 0, 1);

      // Totals
      final subtotal = (summary['subtotal'] as num?)?.toDouble() ?? 0.0;
      final discount = (summary['discount'] as num?)?.toDouble() ?? 0.0;
      final cgst = (summary['cgst'] as num?)?.toDouble() ?? 0.0;
      final sgst = (summary['sgst'] as num?)?.toDouble() ?? 0.0;
      final igst = (summary['igst'] as num?)?.toDouble() ?? 0.0;
      final grandTotal = (summary['grand_total'] as num?)?.toDouble() ?? 0.0;
      final paid = (summary['paid_amount'] as num?)?.toDouble() ?? 0.0;
      final balance = (summary['balance_due'] as num?)?.toDouble() ?? 0.0;

      _bluetooth.printLeftRight("Subtotal:", "Rs.${subtotal.toStringAsFixed(2)}", 0);
      if (discount > 0) {
        _bluetooth.printLeftRight("Discount:", "-Rs.${discount.toStringAsFixed(2)}", 0);
      }
      if (cgst > 0 || sgst > 0) {
        _bluetooth.printLeftRight("CGST:", "Rs.${cgst.toStringAsFixed(2)}", 0);
        _bluetooth.printLeftRight("SGST:", "Rs.${sgst.toStringAsFixed(2)}", 0);
      }
      if (igst > 0) {
        _bluetooth.printLeftRight("IGST:", "Rs.${igst.toStringAsFixed(2)}", 0);
      }

      _bluetooth.printCustom("=" * width, 0, 1);
      _bluetooth.printLeftRight("GRAND TOTAL:", "Rs.${grandTotal.toStringAsFixed(2)}", 1);
      _bluetooth.printCustom("=" * width, 0, 1);

      if (balance > 0) {
        _bluetooth.printLeftRight("Paid:", "Rs.${paid.toStringAsFixed(2)}", 0);
        _bluetooth.printLeftRight("Balance Due:", "Rs.${balance.toStringAsFixed(2)}", 1);
      }

      // UPI QR Code on Receipt for Counter Collection
      if (qr != null && qr.isNotEmpty) {
        _bluetooth.printNewLine();
        _bluetooth.printCustom("Scan & Pay via UPI:", 0, 1);
        _bluetooth.printQRcode(qr, 200, 200, 1);
      }

      _bluetooth.printNewLine();
      _bluetooth.printCustom(footer, 0, 1);
      _bluetooth.printCustom("Powered by KadaiKhata", 0, 1);
      _bluetooth.printNewLine();
      _bluetooth.printNewLine();
      _bluetooth.paperCut();

      return true;
    } catch (e) {
      return false;
    }
  }
}
