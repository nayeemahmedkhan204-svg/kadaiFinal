import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/l10n/app_localizations.dart';
import '../models/customer_model.dart';
import '../providers/customer_provider.dart';
import '14_customer_khata_screen.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _filterHasBalance = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    Provider.of<CustomerProvider>(context, listen: false).fetchCustomers(
      search: query.trim(),
      hasBalance: _filterHasBalance,
    );
  }

  void _showAddCustomerModal() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final gstinCtrl = TextEditingController();
    final creditLimitCtrl = TextEditingController(text: '10000');
    final openingBalCtrl = TextEditingController(text: '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Add Customer / வாடிக்கையாளர் சேர்க்க',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Customer Name * / பெயர்', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number * / அலைபேசி', prefixIcon: Icon(Icons.phone)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address (Optional)', prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address / முகவரி', prefixIcon: Icon(Icons.location_on)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: gstinCtrl,
                        decoration: const InputDecoration(labelText: 'GSTIN (Optional)', prefixIcon: Icon(Icons.badge)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: creditLimitCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Credit Limit ₹', prefixIcon: Icon(Icons.credit_card)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: openingBalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Opening Balance ₹ (Existing Due)', prefixIcon: Icon(Icons.account_balance_wallet)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();
                    if (name.isEmpty || phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter name and phone number.')),
                      );
                      return;
                    }

                    final data = {
                      'name': name,
                      'phone': phone,
                      'email': emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                      'address': addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
                      'gstin': gstinCtrl.text.trim().isNotEmpty ? gstinCtrl.text.trim() : null,
                      'credit_limit': double.tryParse(creditLimitCtrl.text) ?? 10000.0,
                      'opening_balance': double.tryParse(openingBalCtrl.text) ?? 0.0,
                    };

                    final ok = await Provider.of<CustomerProvider>(context, listen: false).addCustomer(data);
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Customer saved successfully!' : 'Failed to save customer.'),
                          backgroundColor: ok ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Save Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final custProv = Provider.of<CustomerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Khata / வாடிக்கையாளர்'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => custProv.fetchCustomers(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomerModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('New Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Outstanding balance header card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Customers Due / நிலுவைத் தொகை',
                        style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${custProv.totalOutstanding.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
                FilterChip(
                  label: const Text('Only Dues'),
                  selected: _filterHasBalance,
                  selectedColor: Colors.red.shade100,
                  onSelected: (sel) {
                    setState(() => _filterHasBalance = sel);
                    custProv.fetchCustomers(search: _searchCtrl.text.trim(), hasBalance: sel);
                  },
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search customer by name or phone...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearch,
            ),
          ),
          const SizedBox(height: 8),

          // Customer list
          Expanded(
            child: custProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : custProv.customers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text('No customers found', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _showAddCustomerModal,
                              child: const Text('Add Customer'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: custProv.customers.length,
                        itemBuilder: (context, index) {
                          final cust = custProv.customers[index];
                          final hasDue = cust.outstandingBalance > 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              leading: CircleAvatar(
                                backgroundColor: hasDue ? Colors.red.shade100 : Colors.green.shade100,
                                child: Text(
                                  cust.name.isNotEmpty ? cust.name[0].toUpperCase() : 'C',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: hasDue ? Colors.red.shade800 : Colors.green.shade800,
                                  ),
                                ),
                              ),
                              title: Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cust.phone ?? '', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                  if (cust.address != null && cust.address!.isNotEmpty)
                                    Text(cust.address!, maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${cust.outstandingBalance.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: hasDue ? Colors.red : Colors.green.shade700,
                                    ),
                                  ),
                                  Text(
                                    hasDue ? 'Due / பாக்கி' : 'Settled',
                                    style: TextStyle(fontSize: 11, color: hasDue ? Colors.red : Colors.green.shade700),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => CustomerKhataScreen(customer: cust)),
                                ).then((_) => custProv.fetchCustomers());
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
