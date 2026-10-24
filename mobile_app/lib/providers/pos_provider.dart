import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/cart_item_model.dart';
import '../models/customer_model.dart';
import '../models/invoice_model.dart';
import '../models/product_model.dart';

class PosProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final AppDatabase _db = AppDatabase();

  final List<CartItemModel> _cartItems = [];
  CustomerModel? _selectedCustomer;
  String _customerName = 'Walk-in Customer';
  String? _customerPhone;
  String? _customerGstin;

  String _paymentMethod = 'cash';
  double _paidAmount = 0.0;
  double _billDiscountAmount = 0.0;
  String? _notes;

  bool _isProcessing = false;
  String? _lastError;
  InvoiceModel? _lastCompletedInvoice;
  Map<String, dynamic>? _lastReceiptPrintData;

  List<CartItemModel> get cartItems => _cartItems;
  CustomerModel? get selectedCustomer => _selectedCustomer;
  String get customerName => _customerName;
  String? get customerPhone => _customerPhone;
  String get paymentMethod => _paymentMethod;
  double get paidAmount => _paidAmount;
  bool get isProcessing => _isProcessing;
  String? get lastError => _lastError;
  InvoiceModel? get lastCompletedInvoice => _lastCompletedInvoice;
  Map<String, dynamic>? get lastReceiptPrintData => _lastReceiptPrintData;

  // --- Cart Calculations ---
  int get itemCount => _cartItems.length;
  double get totalQuantity => _cartItems.fold(0.0, (sum, i) => sum + i.quantity);

  double get subtotal => _cartItems.fold(0.0, (sum, i) => sum + i.grossTotal);
  double get lineDiscounts => _cartItems.fold(0.0, (sum, i) => sum + i.effectiveDiscount);
  double get totalDiscount => lineDiscounts + _billDiscountAmount;

  double get taxableAmount => _cartItems.fold(0.0, (sum, i) => sum + i.taxableValue);
  double get totalTax => _cartItems.fold(0.0, (sum, i) => sum + i.taxAmount);

  double get rawGrandTotal {
    final net = _cartItems.fold(0.0, (sum, i) => sum + i.lineTotal);
    return (net - _billDiscountAmount) > 0 ? (net - _billDiscountAmount) : 0.0;
  }

  double get grandTotal => rawGrandTotal.roundToDouble();
  double get roundOff => grandTotal - rawGrandTotal;

  // --- Cart Actions ---
  void addProduct(ProductModel product, {double qty = 1.0}) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _cartItems[index].quantity += qty;
    } else {
      _cartItems.add(CartItemModel(
        product: product,
        quantity: qty,
        unitPrice: product.sellingPrice,
      ));
    }
    _paidAmount = grandTotal;
    notifyListeners();
  }

  void updateQuantity(int index, double qty) {
    if (index >= 0 && index < _cartItems.length) {
      if (qty <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = qty;
      }
      _paidAmount = grandTotal;
      notifyListeners();
    }
  }

  void updateUnitPrice(int index, double price) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems[index].unitPrice = price;
      _paidAmount = grandTotal;
      notifyListeners();
    }
  }

  void updateLineDiscount(int index, {double percent = 0.0, double amount = 0.0}) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems[index].discountPercent = percent;
      _cartItems[index].discountAmount = amount;
      _paidAmount = grandTotal;
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      _paidAmount = grandTotal;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _selectedCustomer = null;
    _customerName = 'Walk-in Customer';
    _customerPhone = null;
    _customerGstin = null;
    _paymentMethod = 'cash';
    _paidAmount = 0.0;
    _billDiscountAmount = 0.0;
    _notes = null;
    _lastError = null;
    notifyListeners();
  }

  void setCustomer(CustomerModel? customer) {
    _selectedCustomer = customer;
    if (customer != null) {
      _customerName = customer.name;
      _customerPhone = customer.phone;
      _customerGstin = customer.gstin;
    } else {
      _customerName = 'Walk-in Customer';
      _customerPhone = null;
      _customerGstin = null;
    }
    notifyListeners();
  }

  void setCustomCustomerDetails(String name, String? phone, String? gstin) {
    _selectedCustomer = null;
    _customerName = name.isNotEmpty ? name : 'Walk-in Customer';
    _customerPhone = phone;
    _customerGstin = gstin;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    if (method == 'credit') {
      _paidAmount = 0.0;
    } else {
      _paidAmount = grandTotal;
    }
    notifyListeners();
  }

  void setPaidAmount(double amount) {
    _paidAmount = amount;
    notifyListeners();
  }

  // --- POS Checkout Execution ---
  Future<bool> checkout(int businessId) async {
    if (_cartItems.isEmpty) {
      _lastError = 'Cart is empty. Please add items.';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _lastError = null;
    notifyListeners();

    final clientUuid = const Uuid().v4();
    final payload = {
      'client_uuid': clientUuid,
      'customer_id': _selectedCustomer?.id,
      'customer_name': _customerName,
      'customer_phone': _customerPhone,
      'customer_gstin': _customerGstin,
      'payment_method': _paymentMethod,
      'paid_amount': _paidAmount,
      'notes': _notes,
      'items': _cartItems.map((e) => e.toApiItem()).toList(),
    };

    final response = await _api.post(ApiEndpoints.invoices, payload);

    if (response.success && response.data != null) {
      _lastCompletedInvoice = InvoiceModel.fromJson(response.data['invoice']);
      _lastReceiptPrintData = response.data['print_data'] as Map<String, dynamic>?;
      _isProcessing = false;
      notifyListeners();
      return true;
    } else if (response.statusCode == 0) {
      // Offline fallback: Queue locally into SQLite
      await _db.queueOfflineInvoice(clientUuid, businessId, payload);
      _lastError = 'Saved offline. Bill will automatically sync when internet reconnects.';
      _isProcessing = false;
      notifyListeners();
      return true;
    } else {
      _lastError = response.message ?? 'Checkout failed.';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }
}
