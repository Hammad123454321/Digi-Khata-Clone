import 'package:enshaal_khata/shared/models/invoice_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('InvoiceModel parses numeric API values without dropping amounts', () {
    final invoice = InvoiceModel.fromJson({
      'id': 'inv_1',
      'invoice_number': 'INV-1',
      'customer_id': 'cust_1',
      'invoice_type': 'credit',
      'date': '2026-02-14T10:00:00.000Z',
      'subtotal': 1450,
      'tax_amount': 0,
      'discount_amount': 0,
      'total_amount': 1450.0,
      'paid_amount': 0,
      'items': [
        {
          'id': 'item_1',
          'item_id': 'stock_1',
          'item_name': 'Sample',
          'quantity': 1,
          'unit_price': 1450,
          'total_price': 1450.0,
        },
      ],
    });

    expect(invoice.subtotal, '1450');
    expect(invoice.totalAmount, '1450.0');
    expect(invoice.paidAmount, '0');
    expect(invoice.items, isNotNull);
    expect(invoice.items!.single.quantity, '1');
    expect(invoice.items!.single.unitPrice, '1450');
    expect(invoice.items!.single.totalPrice, '1450.0');
  });
}
