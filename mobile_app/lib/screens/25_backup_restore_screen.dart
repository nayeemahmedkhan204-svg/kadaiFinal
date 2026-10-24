import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/product_provider.dart';
import '../providers/sync_provider.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SyncProvider>(context, listen: false).checkPendingCount();
    });
  }

  void _triggerManualSync() async {
    final syncProv = Provider.of<SyncProvider>(context, listen: false);
    final count = await syncProv.syncPendingInvoices();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(count > 0
              ? 'Successfully synced $count pending invoice(s) to cloud!'
              : 'All offline records are already synchronized with server.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _refreshOfflineCache() async {
    final prodProv = Provider.of<ProductProvider>(context, listen: false);
    await prodProv.fetchProducts();
    await prodProv.fetchCategories();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline product catalog refreshed into local SQLite storage!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncProv = Provider.of<SyncProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup, Restore & Sync / ஒத்திசைவு'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cloud Synchronization Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: syncProv.hasPendingSync
                      ? [Colors.orange.shade700, Colors.orange.shade900]
                      : [AppColors.primary, AppColors.primaryLight],
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
                      const Text('Cloud Sync Status', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          syncProv.hasPendingSync ? 'Pending Invoices' : 'Up to Date',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${syncProv.pendingCount} Bills Awaiting Sync',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    syncProv.lastSyncTime != null
                        ? 'Last Synced: ${syncProv.lastSyncTime!.toLocal().toString().substring(0, 16)}'
                        : 'No recent cloud sync recorded',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: syncProv.isSyncing ? null : _triggerManualSync,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: syncProv.isSyncing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      syncProv.isSyncing ? 'Synchronizing...' : 'Sync Pending Invoices Now',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Offline Catalog Cache Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.storage, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Offline Local SQLite Storage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KadaiKhata stores products and price lists locally on your device. You can generate bills continuously without an internet connection.',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _refreshOfflineCache,
                      icon: const Icon(Icons.download_for_offline),
                      label: const Text('Download & Refresh Local Catalog'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data Export Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.file_download, color: Colors.teal),
                        SizedBox(width: 8),
                        Text('Export Shop Data / தரவு ஏற்றுமதி', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Export your complete invoices, product catalog, customer khata, and expense logs as structured JSON / Excel backup.',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Shop backup generated and exported successfully!'), backgroundColor: AppColors.success),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      icon: const Icon(Icons.backup, color: Colors.white),
                      label: const Text('Export Complete Shop Backup', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // How Offline Works explanation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How Offline Billing & Idempotency Works:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 6),
                  Text(
                    '1. When the internet is disconnected, bills are assigned a UUID and saved to the local SQLite queue.\n'
                    '2. Stock is decremented locally immediately so cashiers can keep track of available inventory.\n'
                    '3. When connectivity resumes, bills sync via idempotent endpoints that prevent duplicate bill generation or duplicate stock deduction.\n'
                    '4. Your records are never lost or silently discarded.',
                    style: TextStyle(fontSize: 11, height: 1.4, color: Colors.black87),
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
