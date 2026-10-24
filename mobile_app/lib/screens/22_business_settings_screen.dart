import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/business_model.dart';
import '../providers/business_provider.dart';

class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _legalNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCodeCtrl;
  late TextEditingController _gstinCtrl;
  late TextEditingController _prefixCtrl;
  late TextEditingController _upiIdCtrl;
  late TextEditingController _upiNameCtrl;
  late TextEditingController _footerCtrl;
  late TextEditingController _minStockCtrl;
  bool _isTaxInclusive = true;

  @override
  void initState() {
    super.initState();
    final biz = Provider.of<BusinessProvider>(context, listen: false).currentBusiness;

    _nameCtrl = TextEditingController(text: biz?.name ?? '');
    _legalNameCtrl = TextEditingController(text: biz?.legalName ?? '');
    _phoneCtrl = TextEditingController(text: biz?.phone ?? '');
    _emailCtrl = TextEditingController(text: biz?.email ?? '');
    _addressCtrl = TextEditingController(text: biz?.address ?? '');
    _cityCtrl = TextEditingController(text: biz?.city ?? '');
    _stateCodeCtrl = TextEditingController(text: biz?.stateCode ?? '33');
    _gstinCtrl = TextEditingController(text: biz?.gstin ?? '');
    _prefixCtrl = TextEditingController(text: biz?.invoicePrefix ?? 'INV-');
    _upiIdCtrl = TextEditingController(text: biz?.upiId ?? '');
    _upiNameCtrl = TextEditingController(text: biz?.upiPayeeName ?? '');
    _footerCtrl = TextEditingController(text: biz?.receiptFooterMessage ?? 'நன்றி! மீண்டும் வருக! / Thank you, visit again!');
    _minStockCtrl = TextEditingController(text: (biz?.lowStockThreshold ?? 5).toString());
    _isTaxInclusive = biz?.isTaxInclusive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _legalNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCodeCtrl.dispose();
    _gstinCtrl.dispose();
    _prefixCtrl.dispose();
    _upiIdCtrl.dispose();
    _upiNameCtrl.dispose();
    _footerCtrl.dispose();
    _minStockCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameCtrl.text.trim(),
      'legal_name': _legalNameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      'address': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state_code': _stateCodeCtrl.text.trim(),
      'gstin': _gstinCtrl.text.trim().isNotEmpty ? _gstinCtrl.text.trim() : null,
      'invoice_prefix': _prefixCtrl.text.trim(),
      'upi_id': _upiIdCtrl.text.trim().isNotEmpty ? _upiIdCtrl.text.trim() : null,
      'upi_payee_name': _upiNameCtrl.text.trim().isNotEmpty ? _upiNameCtrl.text.trim() : null,
      'receipt_footer_message': _footerCtrl.text.trim(),
      'low_stock_threshold': int.tryParse(_minStockCtrl.text) ?? 5,
      'is_tax_inclusive': _isTaxInclusive,
    };

    final ok = await Provider.of<BusinessProvider>(context, listen: false).updateBusinessSettings(data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Business settings updated successfully!' : 'Failed to update settings.'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bizProv = Provider.of<BusinessProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop & Billing Settings / கடை அமைப்புகள்'),
        actions: [
          TextButton(
            onPressed: bizProv.isLoading ? null : _saveSettings,
            child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: bizProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Shop Identity Card
                    _SectionHeader(title: 'Shop Identity / கடை விவரங்கள்', icon: Icons.storefront),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(labelText: 'Shop Display Name * / கடை பெயர்'),
                              validator: (v) => v == null || v.isEmpty ? 'Shop name required' : null,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _legalNameCtrl,
                              decoration: const InputDecoration(labelText: 'Legal Business Name (For Invoices)'),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(labelText: 'Shop Phone * / அலைபேசி'),
                                    validator: (v) => v == null || v.isEmpty ? 'Phone required' : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(labelText: 'Email Address'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _addressCtrl,
                              decoration: const InputDecoration(labelText: 'Street Address / முகவரி'),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cityCtrl,
                                    decoration: const InputDecoration(labelText: 'City / ஊர்'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _stateCodeCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'GST State Code (e.g. 33 for TN)',
                                      hintText: '33',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _gstinCtrl,
                              decoration: const InputDecoration(
                                labelText: 'GSTIN (15 Digits, Optional for Composition/Non-GST)',
                                hintText: '33AAAAA0000A1Z5',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Invoice Configuration Card
                    _SectionHeader(title: 'Invoice & POS Configuration', icon: Icons.receipt),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _prefixCtrl,
                                    decoration: const InputDecoration(labelText: 'Invoice Prefix (e.g. INV-)'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _minStockCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Default Low Stock Alert'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              title: const Text('Tax Inclusive Pricing', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('Product selling prices already include GST taxes.'),
                              value: _isTaxInclusive,
                              onChanged: (val) => setState(() => _isTaxInclusive = val),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // UPI & Receipt Card
                    _SectionHeader(title: 'UPI Payment QR & Thermal Bill Footer', icon: Icons.qr_code_2),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _upiIdCtrl,
                              decoration: const InputDecoration(
                                labelText: 'UPI ID / VPA for Dynamic QR (e.g. shop@okaxis)',
                                prefixIcon: Icon(Icons.qr_code),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _upiNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'UPI Payee Name (e.g. Murugan Maligai)',
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _footerCtrl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Receipt Footer Message / வாழ்த்து வாசகம்',
                                prefixIcon: Icon(Icons.chat_bubble_outline),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: bizProv.isLoading ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save All Settings / அமைப்புகளை சேமி',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
        ],
      ),
    );
  }
}
