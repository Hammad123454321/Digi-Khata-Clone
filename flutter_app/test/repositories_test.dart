import 'package:flutter_test/flutter_test.dart';
import 'package:digikhata_clone/core/constants/api_constants.dart';

void main() {
  group('Repository Tests', () {
    test('API Constants are properly defined', () {
      expect(ApiConstants.baseUrlDev, isNotEmpty);
      expect(ApiConstants.baseUrlProd, isNotEmpty);
      expect(ApiConstants.apiPrefix, '/api/v1');
      expect(ApiConstants.requestOtp, '/auth/request-otp');
      expect(ApiConstants.verifyOtp, '/auth/verify-otp');
      expect(ApiConstants.cashTransactions, '/cash/transactions');
      expect(ApiConstants.stockItems, '/stock/items');
      expect(ApiConstants.invoices, '/invoices');
      expect(ApiConstants.customers, '/customers');
      expect(ApiConstants.suppliers, '/suppliers');
      expect(ApiConstants.expenses, '/expenses');
      expect(ApiConstants.staff, '/staff');
      expect(ApiConstants.bankAccounts, '/banks/accounts');
      expect(ApiConstants.reportsSales, '/reports/sales');
    });

    test('API Constants timeouts are defined', () {
      expect(ApiConstants.connectTimeout, isNotNull);
      expect(ApiConstants.receiveTimeout, isNotNull);
      expect(ApiConstants.sendTimeout, isNotNull);
    });
  });
}




