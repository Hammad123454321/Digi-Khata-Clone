import 'package:flutter_test/flutter_test.dart';
import 'package:digikhata_clone/shared/models/cash_transaction_model.dart';
import 'package:digikhata_clone/shared/models/customer_model.dart';
import 'package:digikhata_clone/shared/models/invoice_model.dart';
import 'package:digikhata_clone/shared/models/stock_item_model.dart';

void main() {
  group('Model Tests', () {
    test('CashTransactionModel fromJson', () {
      final json = {
        'id': 1,
        'transaction_type': 'cash_in',
        'amount': '1000.00',
        'date': '2024-01-05T10:00:00Z',
        'source': 'Sales',
        'remarks': 'Daily sales',
        'created_at': '2024-01-05T10:00:00Z',
      };

      final model = CashTransactionModel.fromJson(json);
      expect(model.id, 1);
      expect(model.transactionType, 'cash_in');
      expect(model.amount, '1000.00');
      expect(model.source, 'Sales');
    });

    test('CustomerModel fromJson', () {
      final json = {
        'id': 1,
        'name': 'Test Customer',
        'phone': '923001234567',
        'email': 'test@example.com',
        'address': 'Test Address',
        'is_active': true,
        'balance': '500.00',
      };

      final model = CustomerModel.fromJson(json);
      expect(model.id, 1);
      expect(model.name, 'Test Customer');
      expect(model.phone, '923001234567');
      expect(model.balance, '500.00');
    });

    test('InvoiceModel fromJson', () {
      final json = {
        'id': 1,
        'invoice_number': 'INV-1-000001',
        'customer_id': 1,
        'invoice_type': 'cash',
        'date': '2024-01-05T10:00:00Z',
        'subtotal': '300.00',
        'tax_amount': '30.00',
        'discount_amount': '10.00',
        'total_amount': '320.00',
        'paid_amount': '320.00',
        'items': [
          {
            'id': 1,
            'item_id': 1,
            'item_name': 'Product A',
            'quantity': '2.000',
            'unit_price': '150.00',
            'total_price': '300.00',
          }
        ],
      };

      final model = InvoiceModel.fromJson(json);
      expect(model.id, 1);
      expect(model.invoiceNumber, 'INV-1-000001');
      expect(model.invoiceType, 'cash');
      expect(model.items?.length, 1);
      expect(model.items?.first.itemName, 'Product A');
    });

    test('StockItemModel fromJson', () {
      final json = {
        'id': 1,
        'name': 'Product A',
        'sku': 'PROD-A-001',
        'purchase_price': '100.00',
        'sale_price': '150.00',
        'unit': 'pcs',
        'current_stock': '100.000',
        'min_stock_threshold': '10.000',
        'is_active': true,
      };

      final model = StockItemModel.fromJson(json);
      expect(model.id, 1);
      expect(model.name, 'Product A');
      expect(model.sku, 'PROD-A-001');
      expect(model.currentStock, '100.000');
    });
  });
}












