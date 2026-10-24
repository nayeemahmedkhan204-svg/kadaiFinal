import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final ApiClient _api = ApiClient();
  List<dynamic> _staffMembers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    setState(() => _isLoading = true);
    final res = await _api.get(ApiEndpoints.staff);
    if (res.success && res.data != null) {
      _staffMembers = res.data['members'] as List<dynamic>? ?? [];
    }
    setState(() => _isLoading = false);
  }

  void _showAddStaffModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'cashier';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    const Text('Add Staff Member / பணியாளர் சேர்க்க',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Staff Name * / பெயர்', prefixIcon: Icon(Icons.person)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email Address *', prefixIcon: Icon(Icons.email)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Login Password * / கடவுச்சொல்', prefixIcon: Icon(Icons.lock)),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(labelText: 'Role / பதவி', prefixIcon: Icon(Icons.badge)),
                      items: const [
                        DropdownMenuItem(value: 'cashier', child: Text('Cashier (Billing Only) / காசாளர்')),
                        DropdownMenuItem(value: 'manager', child: Text('Manager (Inventory & Reports) / மேலாளர்')),
                        DropdownMenuItem(value: 'owner', child: Text('Co-Owner (Full Access) / உரிமையாளர்')),
                      ],
                      onChanged: (val) => setModalState(() => role = val!),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final email = emailCtrl.text.trim();
                        final pass = passCtrl.text;
                        if (name.isEmpty || email.isEmpty || pass.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill valid name, email and password (min 6 chars).')),
                          );
                          return;
                        }

                        final res = await _api.post(ApiEndpoints.staff, {
                          'name': name,
                          'email': email,
                          'phone': phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                          'password': pass,
                          'role': role,
                        });

                        if (context.mounted) {
                          Navigator.pop(ctx);
                          if (res.success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Staff member invited successfully!'), backgroundColor: AppColors.success),
                            );
                            _fetchStaff();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res.message ?? 'Failed to add staff.'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Add Staff Member',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff & Cashiers / பணியாளர்கள்'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchStaff),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStaffModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Role Permissions Guide Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                            SizedBox(width: 6),
                            Text('Role Permissions Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text('• Cashier: Quick POS billing, print invoices, view daily cash.', style: TextStyle(fontSize: 12)),
                        Text('• Manager: Billing + inventory management, purchases, supplier payments.', style: TextStyle(fontSize: 12)),
                        Text('• Owner: Full administrative access, P&L reports, staff control.', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Current Staff Members (${_staffMembers.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),

                  if (_staffMembers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text('No staff members registered for this shop.', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ..._staffMembers.map((m) {
                      final user = m['user'] ?? {};
                      final role = (m['role'] ?? 'cashier').toString().toUpperCase();
                      final userName = user['name'] ?? 'Staff Member';
                      final userEmail = user['email'] ?? '';
                      final isOwner = role == 'OWNER';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isOwner ? Colors.purple.shade100 : Colors.blue.shade100,
                            child: Icon(isOwner ? Icons.admin_panel_settings : Icons.person,
                                color: isOwner ? Colors.purple : AppColors.primary),
                          ),
                          title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(userEmail, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOwner ? Colors.purple.shade50 : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isOwner ? Colors.purple.shade800 : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
