class AppConstants {
  static const String appName = 'KadaiKhata';
  static const String appTagline = 'Smart Billing, Inventory & Khata';
  static const String appVersion = '1.0.0';

  // Base API URL (defaults to localhost XAMPP for emulator/device)
  // For Android emulator: 10.0.2.2:8000
  // For physical device over Wi-Fi: your PC IP (e.g., 192.168.1.X:8000)
  static const String defaultBaseUrl = 'http://10.0.2.2:8000/api';

  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keySelectedBusinessId = 'selected_business_id';
  static const String keySelectedBusinessData = 'selected_business_data';
  static const String keyAppLanguage = 'app_language';
  static const String keyPrinterAddress = 'saved_printer_mac';
  static const String keyPrinterPaperSize = 'printer_paper_size'; // 58 or 80

  // GST Slabs
  static const List<double> gstRates = [0.0, 5.0, 12.0, 18.0, 28.0];

  // Standard Units
  static const List<String> units = [
    'PCS',
    'KG',
    'GMS',
    'LTR',
    'ML',
    'PKT',
    'BOX',
    'BAG',
    'MTR',
    'DOZ',
  ];

  // Payment Methods
  static const String payCash = 'cash';
  static const String payUpi = 'upi';
  static const String payBank = 'bank_transfer';
  static const String payCredit = 'credit';
  static const String paySplit = 'split';

  // State Codes for GST
  static const Map<String, String> indianStateCodes = {
    '33': 'Tamil Nadu',
    '32': 'Kerala',
    '29': 'Karnataka',
    '37': 'Andhra Pradesh',
    '36': 'Telangana',
    '27': 'Maharashtra',
    '24': 'Gujarat',
    '07': 'Delhi',
    '09': 'Uttar Pradesh',
    '19': 'West Bengal',
  };
}
