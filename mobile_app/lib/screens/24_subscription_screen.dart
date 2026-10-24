import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/subscription_model.dart';
import '../providers/business_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final ApiClient _api = ApiClient();
  List<dynamic> _availablePlans = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() => _isLoading = true);
    final res = await _api.get(ApiEndpoints.subscriptionPlans);
    if (res.success && res.data != null) {
      _availablePlans = res.data['plans'] as List<dynamic>? ?? [];
    }
    setState(() => _isLoading = false);
  }

  void _upgradePlan(dynamic plan) async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Upgrade to ${plan['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price: ₹${plan['price']} / ${plan['billing_interval']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Text(plan['description'] ?? 'Unlock unlimited billing and cloud backup.'),
              const SizedBox(height: 14),
              const Text(
                'Note: Server verifies secure payment callback before activating paid subscriptions.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final res = await _api.post(ApiEndpoints.subscribePlan, {
                  'plan_id': plan['id'],
                  'payment_method': 'razorpay',
                  'payment_reference': 'MOCK-PAY-${DateTime.now().millisecondsSinceEpoch}',
                });

                if (context.mounted) {
                  if (res.success) {
                    await Provider.of<BusinessProvider>(context, listen: false).fetchBusinessDetails();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Subscribed to ${plan['name']} successfully!'), backgroundColor: AppColors.success),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res.message ?? 'Subscription failed.'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: const Text('Confirm & Subscribe'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bizProv = Provider.of<BusinessProvider>(context);
    final sub = bizProv.currentSubscription;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription & Plans / சந்தா'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              bizProv.fetchBusinessDetails();
              _fetchPlans();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active Plan Card
                  Container(
                    padding: const EdgeInsets.all(20),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Active Plan', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.shade700,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (sub?.status ?? 'Active').toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sub?.planName ?? 'Pro Merchant Trial',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sub != null && sub.isTrial
                              ? 'Trial period valid until ${sub.trialEndsAt?.substring(0, 10) ?? 'N/A'}'
                              : 'Valid until ${sub?.endsAt?.substring(0, 10) ?? 'Never (Unlimited)'}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Divider(color: Colors.white30, height: 24),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _QuotaItem(label: 'Bills / Month', value: 'Unlimited'),
                            _QuotaItem(label: 'Products', value: 'Unlimited'),
                            _QuotaItem(label: 'Offline Sync', value: 'Active'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Plans List Header
                  const Text('Available Plans / சந்தா திட்டங்கள்',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),

                  if (_availablePlans.isEmpty)
                    const Text('No subscription plans available right now.', style: TextStyle(color: Colors.grey))
                  else
                    ..._availablePlans.map((plan) {
                      final isCurrent = sub?.planId == plan['id'];
                      final price = (plan['price'] as num?)?.toDouble() ?? 0.0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: isCurrent ? AppColors.primary : Colors.grey.shade200, width: isCurrent ? 2 : 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(plan['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                  Text(
                                    price == 0 ? 'FREE' : '₹${price.toStringAsFixed(0)} / ${plan['billing_interval'] ?? 'mo'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              if (plan['description'] != null) ...[
                                const SizedBox(height: 6),
                                Text(plan['description'], style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                              ],
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: isCurrent
                                    ? OutlinedButton(
                                        onPressed: null,
                                        child: const Text('Current Plan'),
                                      )
                                    : ElevatedButton(
                                        onPressed: () => _upgradePlan(plan),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        child: const Text('Select Plan / தேர்வு செய்',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                              ),
                            ],
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

class _QuotaItem extends StatelessWidget {
  final String label;
  final String value;

  const _QuotaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
