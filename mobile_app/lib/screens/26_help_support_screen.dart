import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How to connect my Bluetooth Thermal Printer?',
      'a': 'Go to Menu > Bluetooth Printer Setup. Ensure your thermal printer is turned on and paired in your phone\'s Bluetooth settings (Default PIN is usually 0000 or 1234). Tap "Scan Devices" and connect. You can choose between 58mm (handheld) and 80mm (counter) paper width.',
    },
    {
      'q': 'Can I bill customers when the internet is down?',
      'a': 'Yes! KadaiKhata is built offline-first. All products, prices, and bills work locally using your phone\'s internal SQLite database. When internet reconnects, simply tap "Sync Now" in Backup & Restore to synchronize all pending bills to the cloud.',
    },
    {
      'q': 'How does GST calculation work (Intra vs Inter-State)?',
      'a': 'If the buyer and seller are within the same state (e.g. State Code 33 - Tamil Nadu), the GST rate is split equally into CGST (50%) and SGST (50%). If billing an inter-state party, IGST (100%) is applied. Tax-inclusive and tax-exclusive pricing modes are both supported.',
    },
    {
      'q': 'How does Customer Khata work?',
      'a': 'When selecting "Credit (Khata)" at POS checkout, the invoice total is automatically added to the customer\'s debit ledger and outstanding balance. When the customer pays later, open their Khata profile and tap "Record Payment" to credit their balance.',
    },
    {
      'q': 'Can multiple cashiers bill at the same shop?',
      'a': 'Yes. Store owners can add multiple staff cashiers from "Staff & Cashiers" screen with role-based permissions to bill simultaneously on multiple Android phones.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help, Support & FAQs / உதவி'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick Support Contacts Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Need Assistance? / உதவி தேவையா?',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                    'KadaiKhata Support Team',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('We are available Monday to Saturday, 9 AM - 8 PM IST.',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const Divider(color: Colors.white30, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ContactButton(
                        icon: Icons.chat,
                        label: 'WhatsApp',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening WhatsApp support chat at +91 9876543210...')),
                          );
                        },
                      ),
                      _ContactButton(
                        icon: Icons.phone,
                        label: 'Helpline',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dialing KadaiKhata toll-free helpline...')),
                          );
                        },
                      ),
                      _ContactButton(
                        icon: Icons.email,
                        label: 'Email',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening email to support@kadaikhata.com...')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Language Selector Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.translate, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('App Language / பயன்பாட்டு மொழி',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('English'),
                            value: 'en',
                            groupValue: _selectedLanguage,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedLanguage = val);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('தமிழ் (Tamil)'),
                            value: 'ta',
                            groupValue: _selectedLanguage,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedLanguage = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // FAQ Accordion
            const Text('Frequently Asked Questions / அடிக்கடி கேட்கப்படும் கேள்விகள்',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            ..._faqs.map((faq) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ExpansionTile(
                  leading: const Icon(Icons.help_outline, color: AppColors.primary, size: 20),
                  title: Text(faq['q']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
                      child: Text(
                        faq['a']!,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // App Version & Copyright Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} v${AppConstants.appVersion}',
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Engineered for Indian Retailers, Wholesalers & Grocers',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
