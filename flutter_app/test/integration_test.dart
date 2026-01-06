import 'package:flutter_test/flutter_test.dart';
import 'package:digikhata_clone/core/constants/api_constants.dart';
import 'package:digikhata_clone/shared/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('Phone validator - valid Pakistan number with country code', () {
      expect(Validators.phone('923001234567'), isNull);
    });

    test('Phone validator - valid number with leading zero', () {
      expect(Validators.phone('03001234567'), isNull);
    });

    test('Phone validator - invalid format', () {
      expect(Validators.phone('123'), isNotNull);
    });

    test('Phone validator - empty string', () {
      expect(Validators.phone(''), isNotNull);
    });

    test('OTP validator - valid 6 digit OTP', () {
      expect(Validators.otp('123456'), isNull);
    });

    test('OTP validator - invalid length', () {
      expect(Validators.otp('12345'), isNotNull);
    });

    test('OTP validator - non-numeric', () {
      expect(Validators.otp('abcdef'), isNotNull);
    });

    test('Amount validator - valid positive amount', () {
      expect(Validators.amount('100.50'), isNull);
    });

    test('Amount validator - zero amount', () {
      expect(Validators.amount('0'), isNotNull);
    });

    test('Amount validator - negative amount', () {
      expect(Validators.amount('-10'), isNotNull);
    });

    test('Amount validator - invalid format', () {
      expect(Validators.amount('abc'), isNotNull);
    });

    test('Required validator - non-empty string', () {
      expect(Validators.required('test'), isNull);
    });

    test('Required validator - empty string', () {
      expect(Validators.required(''), isNotNull);
    });

    test('Email validator - valid email', () {
      expect(Validators.email('test@example.com'), isNull);
    });

    test('Email validator - invalid email', () {
      expect(Validators.email('invalid-email'), isNotNull);
    });
  });

  group('API Constants Tests', () {
    test('Base URLs are defined', () {
      expect(ApiConstants.baseUrlDev, isNotEmpty);
      expect(ApiConstants.baseUrlProd, isNotEmpty);
    });

    test('API prefix is correct', () {
      expect(ApiConstants.apiPrefix, '/api/v1');
    });

    test('Endpoints are defined', () {
      expect(ApiConstants.requestOtp, isNotEmpty);
      expect(ApiConstants.verifyOtp, isNotEmpty);
      expect(ApiConstants.cashTransactions, isNotEmpty);
    });
  });
}

