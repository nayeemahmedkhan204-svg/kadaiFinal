import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/constants/app_colors.dart';
import '../models/invoice_model.dart';
import '../providers/business_provider.dart';
import '../providers/printer_provider.dart';
import '21_bluetooth_printer_screen.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final InvoiceModel invoice;
  final Map<String, dynamic>? printData;

  const InvoicePreviewScreen({
    super.key,
    required this.invoice,
    this.printData,
  });

  @override
  Widget build(BuildContext context) {
    final business = Provider.of<BusinessProvider>(context).currentBusiness;
    final printer = Provider.of<PrinterProvider>(context);

    // Compute UPI QR string: upi://pay?pa=...
    final upiVpa = business?.upiVpa;
    final upiQrPayload = (upiVpa != null && upiVpa.isNotEmpty)
        ? "upi://pay?pa=$upiVpa&pn=${Uri.encodeComponent(business?.upiName ?? business?.name ?? '')}&am=${invoice.grandTotal.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent('Bill ${invoice.invoiceNumber}')}"
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text("Invoice #${invoice.invoiceNumber}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Invoice PDF',
            onPressed: () => _generateAndSharePdf(context, business),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bill Success Badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 22),
                  SizedBox(width: 8),
                  Text('Bill Completed & Saved', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Thermal Receipt Style Paper Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Shop Header
                    Text(
                      business?.name ?? 'Store Name',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    if (business?.address != null) ...[
                      const SizedBox(height: 2),
                      Text(business!.address!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                    if (business?.phone != null) ...[
                      const SizedBox(height: 2),
                      Text("Ph: ${business!.phone}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                    if (business?.gstin != null) ...[
                      const SizedBox(height: 2),
                      Text("GSTIN: ${business!.gstin!}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],

                    const SizedBox(height: 12),
                    const Divider(thickness: 1),

                    // Invoice Metadata
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Text("Bill No: ${invoice.invoiceNumber}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("Date: ${invoice.invoiceDate}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Text("Customer: ${invoice.customerName}", style: const TextStyle(fontSize: 12)),
                        Text("Mode: ${invoice.paymentMethod.toUpperCase()}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(thickness: 1),

                    // Itemized Line Entries
                    ...invoice.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(
                                      "${item.quantity.toInt()} ${item.unit} x ₹${item.unitPrice.toStringAsFixed(2)} (${item.gstRate.toInt()}% GST)",
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "₹${item.total.toStringAsFixed(2)}",
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 12),
                    const Divider(thickness: 1),

                    // Totals Breakdown
                    _buildSummaryRow("Subtotal", "₹${invoice.subtotal.toStringAsFixed(2)}"),
                    if (invoice.totalDiscount > 0)
                      _buildSummaryRow("Discount", "-₹${invoice.totalDiscount.toStringAsFixed(2)}"),
                    if (invoice.cgstAmount > 0 || invoice.sgstAmount > 0) ...[
                      _buildSummaryRow("CGST", "₹${invoice.cgstAmount.toStringAsFixed(2)}"),
                      _buildSummaryRow("SGST", "₹${invoice.sgstAmount.toStringAsFixed(2)}"),
                    ],
                    if (invoice.igstAmount > 0)
                      _buildSummaryRow("IGST", "₹${invoice.igstAmount.toStringAsFixed(2)}"),
                    if (invoice.roundOff != 0)
                      _buildSummaryRow("Round Off", "₹${invoice.roundOff.toStringAsFixed(2)}"),

                    const Divider(thickness: 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        const Text("GRAND TOTAL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          "₹${invoice.grandTotal.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),

                    if (invoice.balanceDue > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          const Text("Paid Amount:", style: TextStyle(fontSize: 13)),
                          Text("₹${invoice.paidAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          const Text("Balance Due (Khata):", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.error)),
                          Text("₹${invoice.balanceDue.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.error)),
                        ],
                      ),
                    ],

                    // Dynamic UPI QR Code for Counter Collection
                    if (upiQrPayload != null) ...[
                      const SizedBox(height: 16),
                      const Text('Scan & Pay via any UPI App:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      QrImageView(
                        data: upiQrPayload,
                        version: QrVersions.auto,
                        size: 160.0,
                      ),
                      const SizedBox(height: 4),
                      Text(upiVpa, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],

                    const SizedBox(height: 16),
                    Text(
                      business?.receiptFooter ?? 'Thank you! Visit again.',
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Print Action Button
            ElevatedButton.icon(
              onPressed: () async {
                if (printer.isConnected && printData != null) {
                  final printed = await printer.printBill(printData!);
                  if (printed && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Receipt printed successfully!')),
                    );
                  }
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BluetoothPrinterScreen()),
                  );
                }
              },
              icon: const Icon(Icons.print),
              label: Text(printer.isConnected ? 'PRINT THERMAL RECEIPT' : 'CONNECT PRINTER & PRINT'),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: () => _generateAndSharePdf(context, business),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('GENERATE & SHARE PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _generateAndSharePdf(BuildContext context, dynamic business) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(business?.name ?? 'Store Name',
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              ),
              if (business?.address != null)
                pw.Center(child: pw.Text(business!.address!, style: const pw.TextStyle(fontSize: 10))),
              if (business?.gstin != null)
                pw.Center(child: pw.Text('GSTIN: ${business!.gstin!}', style: const pw.TextStyle(fontSize: 10))),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.between,
                children: [
                  pw.Text('Invoice No: ${invoice.invoiceNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: ${invoice.invoiceDate}'),
                ],
              ),
              pw.Text('Customer: ${invoice.customerName}'),
              pw.Divider(),
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Qty', 'Rate', 'GST', 'Total (Rs)'],
                data: invoice.items
                    .map((i) => [
                          i.productName,
                          "${i.quantity} ${i.unit}",
                          i.unitPrice.toStringAsFixed(2),
                          "${i.gstRate.toInt()}%",
                          i.total.toStringAsFixed(2),
                        ])
                    .toList(),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grand Total:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Rs. ${invoice.grandTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: 'Invoice_${invoice.invoiceNumber}.pdf');
  }
}
