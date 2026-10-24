class ApiEndpoints {
  // Public
  static const String health = '/health';
  static const String register = '/v1/auth/register';
  static const String login = '/v1/auth/login';
  static const String plans = '/v1/plans';

  // Auth & Profile
  static const String me = '/v1/auth/me';
  static const String profile = '/v1/auth/profile';
  static const String logout = '/v1/auth/logout';

  // Businesses
  static const String businesses = '/v1/businesses';
  static const String currentBusiness = '/v1/business/current';

  // Categories
  static const String categories = '/v1/categories';

  // Products
  static const String products = '/v1/products';
  static const String lowStockProducts = '/v1/products/low-stock';
  static String adjustStock(int id) => '/v1/products/$id/adjust-stock';

  // Invoices & Billing
  static const String invoices = '/v1/billing/invoices';
  static String invoiceDetails(int id) => '/v1/billing/invoices/$id';
  static String cancelInvoice(int id) => '/v1/billing/invoices/$id/cancel';
  static String returnInvoice(int id) => '/v1/billing/invoices/$id/return';

  // Customers & Khata
  static const String customers = '/v1/customers';
  static String customerDetails(int id) => '/v1/customers/$id';
  static String customerPayment(int id) => '/v1/customers/$id/payment';
  static String customerLedger(int id) => '/v1/customers/$id/ledger';

  // Payments
  static const String payments = '/v1/payments';

  // Suppliers & Purchases
  static const String suppliers = '/v1/suppliers';
  static String supplierDetails(int id) => '/v1/suppliers/$id';
  static String supplierPayment(int id) => '/v1/suppliers/$id/payment';
  static const String purchases = '/v1/purchases';
  static String purchaseDetails(int id) => '/v1/purchases/$id';

  // Expenses
  static const String expenses = '/v1/expenses';
  static const String expenseCategories = '/v1/expenses/categories';

  // Reports
  static const String reportDashboard = '/v1/reports/dashboard';
  static const String reportProfitLoss = '/v1/reports/profit-and-loss';
  static const String reportGstSummary = '/v1/reports/gst-summary';
  static const String reportSales = '/v1/reports/sales';
  static const String reportCustomerOutstanding = '/v1/reports/customer-outstanding';
  static const String reportStock = '/v1/reports/stock';

  // Offline Sync
  static const String syncPull = '/v1/sync/pull';
  static const String syncPush = '/v1/sync/push';

  // Staff Management
  static const String staff = '/v1/staff';

  // Subscription
  static const String subscriptionCurrent = '/v1/subscription/current';
  static const String subscriptionSubscribe = '/v1/subscription/subscribe';
  static const String subscriptionPlans = plans;
  static const String subscribePlan = subscriptionSubscribe;
}
