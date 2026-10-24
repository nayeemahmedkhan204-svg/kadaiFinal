import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/business_model.dart';
import '../providers/auth_provider.dart';
import '../providers/business_provider.dart';

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstinController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  String _selectedStateCode = '33';
  String _selectedBusinessType = 'grocery';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _createNewBusiness() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter store name and phone number')),
      );
      return;
    }

    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await businessProvider.createBusiness({
      'name': name,
      'business_type': _selectedBusinessType,
      'phone': phone,
      'gstin': _gstinController.text.trim().isNotEmpty ? _gstinController.text.trim() : null,
      'address': _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      'city': _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
      'state': AppConstants.indianStateCodes[_selectedStateCode] ?? 'Tamil Nadu',
      'state_code': _selectedStateCode,
    });

    if (success && mounted) {
      await authProvider.fetchUserProfile();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store created and activated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final businessProvider = Provider.of<BusinessProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shops & Stores'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Active Store Card
            const Text(
              'ACTIVE STORE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              color: AppColors.primary.withOpacity(0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.store, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            businessProvider.currentBusiness?.name ?? 'No store selected',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            "GSTIN: ${businessProvider.currentBusiness?.gstin ?? 'None'} • ${businessProvider.currentBusiness?.state ?? ''}",
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: AppColors.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Switch to another store
            if (authProvider.businesses.length > 1) ...[
              const Text(
                'SWITCH TO OTHER SHOP',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              ...authProvider.businesses
                  .where((b) => b.id != businessProvider.currentBusiness?.id)
                  .map((b) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.store_mall_directory),
                          title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(b.businessType),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              await businessProvider.switchBusiness(b);
                              if (mounted) Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                            child: const Text('Switch', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      )),
              const SizedBox(height: 20),
            ],

            // Add New Store
            const Text(
              'ADD NEW SHOP',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Store Name *', prefixIcon: Icon(Icons.store)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedBusinessType,
                      decoration: const InputDecoration(labelText: 'Business Type', prefixIcon: Icon(Icons.category)),
                      items: const [
                        DropdownMenuItem(value: 'grocery', child: Text('Grocery & Provisions')),
                        DropdownMenuItem(value: 'tea_stall', child: Text('Tea Shop & Snack Bar')),
                        DropdownMenuItem(value: 'retail', child: Text('General Retail Store')),
                        DropdownMenuItem(value: 'wholesale', child: Text('Wholesale & Trader')),
                        DropdownMenuItem(value: 'street_vendor', child: Text('Street Vendor / Quick Counter')),
                      ],
                      onChanged: (val) => setState(() => _selectedBusinessType = val!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Store Phone *', prefixIcon: Icon(Icons.phone)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _gstinController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'GSTIN (Optional)', prefixIcon: Icon(Icons.badge)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedStateCode,
                      decoration: const InputDecoration(labelText: 'State (for GST)', prefixIcon: Icon(Icons.location_on)),
                      items: AppConstants.indianStateCodes.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text("${e.value} (${e.key})")))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedStateCode = val!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City / Town', prefixIcon: Icon(Icons.location_city)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.map)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: businessProvider.isLoading ? null : _createNewBusiness,
                        icon: const Icon(Icons.add_business),
                        label: const Text('Add & Launch Store'),
                      ),
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
