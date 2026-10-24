import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/database/app_database.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class SyncProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final AppDatabase _db = AppDatabase();

  int _pendingCount = 0;
  bool _isSyncing = false;
  String? _syncMessage;
  DateTime? _lastSyncTime;

  int get pendingCount => _pendingCount;
  bool get isSyncing => _isSyncing;
  String? get syncMessage => _syncMessage;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get hasPendingSync => _pendingCount > 0;

  Future<void> checkPending(int businessId) async {
    final pending = await _db.getPendingInvoices(businessId);
    _pendingCount = pending.length;
    notifyListeners();
  }

  Future<bool> syncNow(int businessId) async {
    _isSyncing = true;
    _syncMessage = 'Syncing offline records...';
    notifyListeners();

    try {
      // 1. Pull latest catalog updates
      final pullRes = await _api.get(ApiEndpoints.syncPull);
      if (pullRes.success && pullRes.data != null) {
        if (pullRes.data['products'] != null) {
          await _db.cacheProducts(pullRes.data['products']);
        }
      }

      // 2. Push pending offline bills
      final pending = await _db.getPendingInvoices(businessId);
      if (pending.isNotEmpty) {
        final invoicesPayload = pending.map((p) {
          final payload = jsonDecode(p['payload'] as String);
          return payload;
        }).toList();

        final pushRes = await _api.post(ApiEndpoints.syncPush, {
          'device_id': 'android-app-terminal',
          'invoices': invoicesPayload,
        });

        if (pushRes.success && pushRes.data != null) {
          final synced = pushRes.data['results']['synced'] as List<dynamic>? ?? [];
          for (var s in synced) {
            final uuid = s['client_uuid'];
            if (uuid != null) {
              await _db.markInvoiceSynced(uuid);
            }
          }
        }
      }

      await checkPending(businessId);
      _isSyncing = false;
      _syncMessage = 'Sync completed successfully.';
      _lastSyncTime = DateTime.now();
      notifyListeners();
      return true;
    } catch (e) {
      _isSyncing = false;
      _syncMessage = 'Sync failed: $e';
      notifyListeners();
      return false;
    }
  }
}
