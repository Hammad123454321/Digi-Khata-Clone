import 'package:enshaal_khata/shared/models/customer_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CustomerModel keeps numeric balance from API payload', () {
    final customer = CustomerModel.fromJson({
      'id': 'cust_1',
      'name': 'Test Customer',
      'balance': 1450.5,
    });

    expect(customer.balance, '1450.5');
  });
}
