import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/business_model.dart';
import '../models/cart_item_model.dart';
import '../models/invoice_model.dart';
import '../models/product_model.dart';
import '../providers/business_provider.dart';
import '../providers/printer_provider.dart';

class BluetoothPrinterScreen extends StatefulWidget {
  const BluetoothPrinterScreen({super.key});

  @override
  State<BluetoothPrinterScreen> createState() => _BluetoothPrinterScreenState();
}

class _BluetoothPrinterScreenState extends State<BluetoothPrinterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrinterProvider>(context, listen: false).init();
    });
  }

  void _printTestBill() async {
    final printerProv = Provider.of<PrinterProvider>(context, listen: false);
    final biz = Provider.of<BusinessProvider>(context, listen: false).currentBusiness ??
        BusinessModel(
          id: 1,
          name: 'KadaiKhata Store',
          legalName: 'KadaiKhata Retail Pvt Ltd',
          phone: '9876543210',
          stateCode: '33',
          upiId: 'shop@okaxis',
          upiPayeeName: 'KadaiKhata Store',
        );

    final dummyInvoice = InvoiceModel(
      id: 0,
      businessId: biz.id,
      invoiceNumber: 'TEST-0001',
      invoiceDate: DateTime.now().toIso8601String().substring(0, 10),
      subtotal: 100.0,
      discountAmount: 0.0,
      taxableAmount: 95.24,
      cgst: 2.38,
      sgst: 2.38,
      igst: 0.0,
      totalTax: 4.76,
      grandTotal: 100.0,
      roundOff: 0.0,
      paymentMethod: 'cash',
      paymentStatus: 'paid',
      paidAmount: 100.0,
      balanceAmount: 0.0,
      items: [
        InvoiceItemModel(
          id: 1,
          invoiceId: 0,
          productId: 1,
          productName: 'Sample Tea Powder 500g',
          quantity: 1,
          unit: 'PKT',
          unitPrice: 100.0,
          taxRate: 5.0,
          taxAmount: 4.76,
          totalAmount: 100.0,
        ),
      ],
    );

    final ok = await printerProv.printReceipt(dummyInvoice, biz);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Test receipt sent to printer!' : 'Printer not connected or failed to print.'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final printerProv = Provider.of<PrinterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Thermal Printer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Scan for Bluetooth Printers',
            onPressed: () => printerProv.scanDevices(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: printerProv.isConnected ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: printerProv.isConnected ? Colors.green.shade300 : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: printerProv.isConnected ? Colors.green : Colors.grey,
                    child: const Icon(Icons.print, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          printerProv.isConnected ? 'Printer Connected' : 'Printer Disconnected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: printerProv.isConnected ? Colors.green.shade900 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          printerProv.selectedDevice != null
                              ? '${printerProv.selectedDevice!.name} (${printerProv.selectedDevice!.address})'
                              : 'No Bluetooth device selected',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (printerProv.isConnected)
                    OutlinedButton(
                      onPressed: () => printerProv.disconnect(),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Disconnect'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Paper Size Selection
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Receipt Paper Size / ரசீது அளவு',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<int>(
                            title: const Text('58mm (2 Inch)'),
                            subtitle: const Text('Handheld / Mobile POS'),
                            value: 58,
                            groupValue: printerProv.paperWidthMm,
                            onChanged: (val) {
                              if (val != null) printerProv.setPaperWidth(val);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<int>(
                            title: const Text('80mm (3 Inch)'),
                            subtitle: const Text('Desktop / Counter POS'),
                            value: 80,
                            groupValue: printerProv.paperWidthMm,
                            onChanged: (val) {
                              if (val != null) printerProv.setPaperWidth(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions: Print Test Receipt
            ElevatedButton.icon(
              onPressed: _printTestBill,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.receipt, color: Colors.white),
              label: const Text('Print Test Receipt / சோதனை ரசீது',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 20),

            // Paired / Discovered Devices Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Available Bluetooth Devices',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => printerProv.scanDevices(),
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Scan Devices'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Devices List
            if (printerProv.devices.isEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.bluetooth_searching, size: 48, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('No paired Bluetooth printers found', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          'Make sure your thermal printer is turned on and paired in your phone\'s Android Bluetooth settings.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...printerProv.devices.map((device) {
                final isCurrent = printerProv.selectedDevice?.address == device.address;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isCurrent && printerProv.isConnected ? Colors.green : Colors.transparent),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.print_outlined, color: AppColors.primary),
                    title: Text(device.name ?? 'Thermal Printer', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(device.address ?? ''),
                    trailing: isCurrent && printerProv.isConnected
                        ? const Chip(
                            label: Text('Connected', style: TextStyle(color: Colors.white, fontSize: 12)),
                            backgroundColor: Colors.green,
                          )
                        : ElevatedButton(
                            onPressed: () => printerProv.connect(device),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size(80, 36),
                            ),
                            child: const Text('Connect', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                  ),
                );
              }),

            const SizedBox(height: 20),

            // Setup tips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline, color: Colors.orange, size: 18),
                      SizedBox(width: 6),
                      Text('Printer Setup Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    '1. Turn on your ESC/POS thermal printer (e.g. Everycom, BluPrint, HOIN, TVS, NGX).\n'
                    '2. Open your phone\'s Bluetooth Settings and pair the printer (Default PIN: 0000 or 1234).\n'
                    '3. Return to this screen, tap "Scan Devices", and press "Connect".\n'
                    '4. Test by pressing "Print Test Receipt".',
                    style: TextStyle(fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
