import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'kadaikhata_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Cached products for offline barcode scanning & cart
        await db.execute('''
          CREATE TABLE local_products (
            id INTEGER PRIMARY KEY,
            business_id INTEGER,
            category_id INTEGER,
            name TEXT NOT NULL,
            sku TEXT,
            barcode TEXT,
            unit TEXT,
            purchase_cost REAL,
            selling_price REAL,
            wholesale_price REAL,
            gst_rate REAL,
            hsn_code TEXT,
            is_tax_inclusive INTEGER,
            current_stock REAL,
            min_stock_threshold REAL,
            is_active INTEGER,
            updated_at TEXT
          )
        ''');

        // Cached categories
        await db.execute('''
          CREATE TABLE local_categories (
            id INTEGER PRIMARY KEY,
            business_id INTEGER,
            name TEXT NOT NULL,
            slug TEXT,
            color TEXT,
            icon TEXT
          )
        ''');

        // Cached customers
        await db.execute('''
          CREATE TABLE local_customers (
            id INTEGER PRIMARY KEY,
            business_id INTEGER,
            name TEXT NOT NULL,
            phone TEXT,
            current_balance REAL,
            credit_limit REAL
          )
        ''');

        // Pending invoices queue (offline-first sync)
        await db.execute('''
          CREATE TABLE pending_invoices (
            client_uuid TEXT PRIMARY KEY,
            business_id INTEGER,
            invoice_number TEXT,
            payload TEXT NOT NULL,
            sync_status TEXT DEFAULT 'pending',
            retry_count INTEGER DEFAULT 0,
            error_message TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        // Pending payments queue
        await db.execute('''
          CREATE TABLE pending_payments (
            id TEXT PRIMARY KEY,
            business_id INTEGER,
            customer_id INTEGER,
            amount REAL,
            payment_mode TEXT,
            payload TEXT NOT NULL,
            sync_status TEXT DEFAULT 'pending',
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // --- Offline Products Cache ---
  Future<void> cacheProducts(List<dynamic> products) async {
    final db = await database;
    final batch = db.batch();
    for (var p in products) {
      batch.insert(
        'local_products',
        {
          'id': p['id'],
          'business_id': p['business_id'],
          'category_id': p['category_id'],
          'name': p['name'],
          'sku': p['sku'],
          'barcode': p['barcode'],
          'unit': p['unit'] ?? 'PCS',
          'purchase_cost': (p['purchase_cost'] as num?)?.toDouble() ?? 0.0,
          'selling_price': (p['selling_price'] as num?)?.toDouble() ?? 0.0,
          'wholesale_price': (p['wholesale_price'] as num?)?.toDouble(),
          'gst_rate': (p['gst_rate'] as num?)?.toDouble() ?? 0.0,
          'hsn_code': p['hsn_code'],
          'is_tax_inclusive': (p['is_tax_inclusive'] == true || p['is_tax_inclusive'] == 1) ? 1 : 0,
          'current_stock': (p['current_stock'] as num?)?.toDouble() ?? 0.0,
          'min_stock_threshold': (p['min_stock_threshold'] as num?)?.toDouble() ?? 5.0,
          'is_active': (p['is_active'] == true || p['is_active'] == 1) ? 1 : 0,
          'updated_at': p['updated_at'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedProducts({String? search, String? barcode}) async {
    final db = await database;
    if (barcode != null && barcode.isNotEmpty) {
      return await db.query('local_products', where: 'barcode = ?', whereArgs: [barcode]);
    }
    if (search != null && search.isNotEmpty) {
      return await db.query(
        'local_products',
        where: 'name LIKE ? OR sku LIKE ? OR barcode LIKE ?',
        whereArgs: ['%$search%', '%$search%', '%$search%'],
      );
    }
    return await db.query('local_products', orderBy: 'name ASC');
  }

  // --- Offline Queue Handling ---
  Future<void> queueOfflineInvoice(String clientUuid, int businessId, Map<String, dynamic> invoicePayload) async {
    final db = await database;
    await db.insert(
      'pending_invoices',
      {
        'client_uuid': clientUuid,
        'business_id': businessId,
        'invoice_number': invoicePayload['invoice_number'] ?? 'OFFLINE',
        'payload': jsonEncode(invoicePayload),
        'sync_status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingInvoices(int businessId) async {
    final db = await database;
    return await db.query(
      'pending_invoices',
      where: 'business_id = ? AND sync_status = ?',
      whereArgs: [businessId, 'pending'],
    );
  }

  Future<void> markInvoiceSynced(String clientUuid) async {
    final db = await database;
    await db.update(
      'pending_invoices',
      {'sync_status': 'synced'},
      where: 'client_uuid = ?',
      whereArgs: [clientUuid],
    );
  }

  Future<void> markInvoiceFailed(String clientUuid, String error) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE pending_invoices
      SET sync_status = 'failed', retry_count = retry_count + 1, error_message = ?
      WHERE client_uuid = ?
    ''', [error, clientUuid]);
  }
}
