# KadaiKhata — Shop Billing & Inventory Management System

**KadaiKhata** is a complete, production-ready Shop Billing & Inventory Management application engineered specifically for Indian small businesses, retail shops, grocery stores (maligai kadai), tea stalls, wholesalers, and street traders.

---

## 🏛️ Project Architecture & Repository Structure

```
C:\xampp\htdocs\Shop\
├── backend/                  # Laravel 12.x REST API & Web Admin Panel
│   ├── app/
│   │   ├── Http/Controllers/Api/  # 12 Specialized REST API Controllers
│   │   ├── Http/Controllers/Admin/ # Web Admin Panel Controller
│   │   ├── Http/Middleware/       # Multi-tenant isolation & Sanctum middleware
│   │   └── Models/                # 20 Eloquent Models with atomic transactions & relationships
│   ├── database/
│   │   ├── migrations/            # 11 Database Migrations (22 normalized tables)
│   │   └── seeders/               # Pre-populated demo store, products, customers, invoices
│   ├── resources/views/admin/     # Blade + Bootstrap 5 Admin Panel views
│   ├── routes/                    # API (v1) and Web routes (72 registered endpoints)
│   └── tests/Feature/             # 14 Passing PHPUnit Feature Tests (94 assertions)
│
├── mobile_app/               # Flutter & Dart Android Mobile Application
│   ├── lib/
│   │   ├── core/                  # Database, Bluetooth printer, theme, network, localization
│   │   │   ├── database/          # SQLite offline sync queue & local caching
│   │   │   ├── printer/           # ESC/POS Bluetooth Thermal Printing (58mm/80mm) + UPI QR
│   │   │   ├── l10n/              # English & Tamil (தமிழ்) localization
│   │   │   └── network/           # REST ApiClient with token interceptors
│   │   ├── models/                # 12 Strongly-typed Dart data models
│   │   ├── providers/             # 9 Provider state management classes
│   │   └── screens/               # All 26 Production Screens + Main Navigation Shell
│   │       ├── 01_splash_screen.dart
│   │       ├── 02_onboarding_screen.dart
│   │       ├── 03_auth_screen.dart
│   │       ├── 04_business_setup_screen.dart
│   │       ├── 05_dashboard_screen.dart
│   │       ├── 06_quick_billing_pos_screen.dart
│   │       ├── 07_invoice_preview_screen.dart
│   │       ├── 08_sales_history_screen.dart
│   │       ├── 09_product_management_screen.dart
│   │       ├── 10_product_categories_screen.dart
│   │       ├── 11_inventory_stock_alerts_screen.dart
│   │       ├── 12_purchase_management_screen.dart
│   │       ├── 13_customer_management_screen.dart
│   │       ├── 14_customer_khata_screen.dart
│   │       ├── 15_supplier_management_screen.dart
│   │       ├── 16_expenses_screen.dart
│   │       ├── 17_payments_collections_screen.dart
│   │       ├── 18_gst_reports_screen.dart
│   │       ├── 19_profit_loss_screen.dart
│   │       ├── 20_reports_screen.dart
│   │       ├── 21_bluetooth_printer_screen.dart
│   │       ├── 22_business_settings_screen.dart
│   │       ├── 23_staff_management_screen.dart
│   │       ├── 24_subscription_screen.dart
│   │       ├── 25_backup_restore_screen.dart
│   │       ├── 26_help_support_screen.dart
│   │       └── main_navigation_screen.dart
│   └── pubspec.yaml               # Flutter 3.x dependencies
│
├── database/                 # Standalone MySQL Scripts
│   ├── schema.sql                 # Complete MySQL DDL Schema dump
│   └── seed_demo_data.sql         # Seed script with realistic Tamil Nadu retail store data
│
└── docs/                     # Full Documentation Suite
    ├── API_DOCUMENTATION.md       # Complete OpenAPI / Markdown REST API specification
    ├── DATABASE_SCHEMA.md         # Data dictionary & ER architecture
    ├── DEPLOYMENT_GUIDE.md        # Local XAMPP, VPS (Nginx + PHP 8.2-FPM), & cPanel hosting
    ├── BACKUP_RESTORE.md          # Automated MySQL dump scripts & SQLite recovery
    └── BUILD_AND_SIGNING_GUIDE.md # Android APK / AAB compilation & release signing guide
```

---

## ⚡ Quickstart

### 1. Backend Setup (Local XAMPP)
1. Start Apache & MySQL in XAMPP.
2. In MySQL, ensure database `kadaikhata` exists:
   ```powershell
   C:\xampp\mysql\bin\mysql.exe -u root -e "CREATE DATABASE IF NOT EXISTS kadaikhata CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
   ```
3. Run migrations and seed data:
   ```powershell
   cd C:\xampp\htdocs\Shop\backend
   C:\xampp\php\php.exe artisan migrate --seed
   ```
4. Run automated test suite:
   ```powershell
   C:\xampp\php\php.exe artisan test
   ```
5. Access the Web Admin Panel at `http://localhost/Shop/backend/public/admin`.

### 2. Pre-Populated Accounts
| Role | Email | Password | Shop Name |
|---|---|---|---|
| **Super Admin** | `admin@kadaikhata.com` | `password123` | Platform Control |
| **Store Owner** | `shopowner@gmail.com` | `password123` | Sri Murugan Maligai Store |
| **Cashier Staff** | `cashier@gmail.com` | `password123` | Sri Murugan Maligai Store |

### 3. Mobile App Build
```bash
cd C:\xampp\htdocs\Shop\mobile_app
flutter pub get
flutter build apk --release
```

---

## 🌟 Key Features

- **⚡ Fast POS Billing**: Barcode scanning, tax-inclusive / exclusive pricing, intra-state (CGST + SGST) and inter-state (IGST) taxation.
- **🖨️ Wireless Bluetooth Printing**: Direct ESC/POS printing on 58mm and 80mm thermal receipt printers with dynamic UPI QR code.
- **📒 Customer Khata (Udhar)**: Reconciled credit ledgers, payment collection tracking, WhatsApp reminders.
- **📦 Stock & Purchasing**: Atomic stock deduction on bill completion, stock movement audit trail, supplier purchase orders.
- **📊 True Accounting P&L**: Net Sales - COGS = Gross Profit; Gross Profit - Operating Expenses = Net Profit.
- **📶 Offline-First Operation**: Local SQLite database with idempotent sync queue that prevents duplicate bills or duplicate stock deductions when internet reconnects.
- **🌐 Bilingual**: English and Tamil (தமிழ்) language localization.
