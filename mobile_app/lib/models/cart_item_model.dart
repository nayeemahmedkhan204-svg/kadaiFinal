import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  double quantity;
  double unitPrice;
  double discountPercent;
  double discountAmount;

  CartItemModel({
    required this.product,
    this.quantity = 1.0,
    required this.unitPrice,
    this.discountPercent = 0.0,
    this.discountAmount = 0.0,
  });

  double get grossTotal => quantity * unitPrice;

  double get effectiveDiscount {
    if (discountAmount > 0) return discountAmount;
    if (discountPercent > 0) return (grossTotal * (discountPercent / 100));
    return 0.0;
  }

  double get netTotal => (grossTotal - effectiveDiscount) > 0 ? (grossTotal - effectiveDiscount) : 0.0;

  double get taxableValue {
    if (product.isTaxInclusive && product.gstRate > 0) {
      return netTotal / (1 + (product.gstRate / 100));
    }
    return netTotal;
  }

  double get taxAmount {
    if (product.isTaxInclusive && product.gstRate > 0) {
      return netTotal - taxableValue;
    }
    return taxableValue * (product.gstRate / 100);
  }

  double get lineTotal {
    if (product.isTaxInclusive) {
      return netTotal;
    }
    return taxableValue + taxAmount;
  }

  Map<String, dynamic> toApiItem() {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'sku': product.sku,
      'hsn_code': product.hsnCode,
      'unit': product.unit,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount_percent': discountPercent,
      'discount_amount': effectiveDiscount,
      'gst_rate': product.gstRate,
      'is_tax_inclusive': product.isTaxInclusive,
    };
  }
}
