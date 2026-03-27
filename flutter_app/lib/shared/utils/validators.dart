import 'package:reactive_forms/reactive_forms.dart';
import '../../core/localization/app_localizations.dart';

/// Form Validators (for standard Flutter forms)
/// Use AppValidators for standard forms, ReactiveValidators for reactive_forms
class AppValidators {
  AppValidators._();

  static String _fieldIsRequired(
    AppLocalizations? loc,
    String fieldName,
  ) {
    if (loc == null) {
      return '$fieldName is required';
    }
    return loc.fieldIsRequired.replaceAll('{field}', fieldName);
  }

  static String _fieldMustBeAtLeast(
    AppLocalizations? loc,
    String fieldName,
    int min,
  ) {
    if (loc == null) {
      return '$fieldName must be at least $min characters';
    }
    return loc.fieldMustBeAtLeast
        .replaceAll('{field}', fieldName)
        .replaceAll('{min}', min.toString());
  }

  static String _fieldMustBeAtMost(
    AppLocalizations? loc,
    String fieldName,
    int max,
  ) {
    if (loc == null) {
      return '$fieldName must be at most $max characters';
    }
    return loc.fieldMustBeAtMost
        .replaceAll('{field}', fieldName)
        .replaceAll('{max}', max.toString());
  }

  /// Phone number validator (Pakistan format)
  static String? phone(String? value, [AppLocalizations? loc]) {
    if (value == null || value.isEmpty) {
      return _fieldIsRequired(loc, loc?.phone ?? 'Phone number');
    }
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.startsWith('92')) {
      if (cleaned.length != 12) {
        return loc?.invalidPhoneNumberFormat ?? 'Invalid phone number format';
      }
    } else if (cleaned.startsWith('0')) {
      if (cleaned.length != 11) {
        return loc?.invalidPhoneNumberFormat ?? 'Invalid phone number format';
      }
    } else if (cleaned.length != 10) {
      return loc?.invalidPhoneNumberFormat ?? 'Invalid phone number format';
    }
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return loc?.phoneDigitsOnly ?? 'Phone number must contain only digits';
    }
    return null;
  }

  /// OTP validator (6 digits)
  static String? otp(String? value, [AppLocalizations? loc]) {
    if (value == null || value.isEmpty) {
      return loc?.otpRequired ?? 'OTP is required';
    }
    if (value.length != 6) {
      return loc?.otpMustBe6Digits ?? 'OTP must be 6 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return loc?.otpDigitsOnly ?? 'OTP must contain only digits';
    }
    return null;
  }

  /// PIN validator (4 digits)
  static String? pin(String? value, [AppLocalizations? loc]) {
    if (value == null || value.isEmpty) {
      return loc?.pinRequired ?? 'PIN is required';
    }
    if (value.length != 4) {
      return loc?.pinMustBe4Digits ?? 'PIN must be 4 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return loc?.pinDigitsOnly ?? 'PIN must contain only digits';
    }
    return null;
  }

  /// Required field validator
  static String? required(
    String? value, [
    String? fieldName,
    AppLocalizations? loc,
  ]) {
    if (value == null || value.trim().isEmpty) {
      final name = fieldName ?? (loc?.thisField ?? 'This field');
      return _fieldIsRequired(loc, name);
    }
    return null;
  }

  /// Email validator
  static String? email(String? value, [AppLocalizations? loc]) {
    if (value == null || value.isEmpty) {
      return loc?.emailRequired ?? 'Email is required';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return loc?.invalidEmailAddress ?? 'Please enter a valid email address';
    }
    return null;
  }

  /// Amount validator (positive decimal)
  static String? amount(String? value, [AppLocalizations? loc]) {
    if (value == null || value.isEmpty) {
      return loc?.amountRequired ?? 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return loc?.invalidAmount ?? 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return loc?.amountMustBeGreaterThanZero ??
          'Amount must be greater than 0';
    }
    return null;
  }

  /// Quantity validator (positive decimal)
  static String? quantity(String? value, [AppLocalizations? loc]) {
    if (value == null || value.isEmpty) {
      return loc?.quantityRequired ?? 'Quantity is required';
    }
    final qty = double.tryParse(value);
    if (qty == null) {
      return loc?.invalidQuantity ?? 'Please enter a valid quantity';
    }
    if (qty <= 0) {
      return loc?.quantityMustBeGreaterThanZero ??
          'Quantity must be greater than 0';
    }
    return null;
  }

  /// Min length validator
  static String? minLength(
    String? value,
    int min, [
    String? fieldName,
    AppLocalizations? loc,
  ]) {
    if (value == null || value.length < min) {
      final name = fieldName ?? (loc?.thisField ?? 'This field');
      return _fieldMustBeAtLeast(loc, name, min);
    }
    return null;
  }

  /// Max length validator
  static String? maxLength(
    String? value,
    int max, [
    String? fieldName,
    AppLocalizations? loc,
  ]) {
    if (value != null && value.length > max) {
      final name = fieldName ?? (loc?.thisField ?? 'This field');
      return _fieldMustBeAtMost(loc, name, max);
    }
    return null;
  }
}

/// Reactive Forms Validators (for reactive_forms package)
class ReactiveValidators {
  ReactiveValidators._();

  /// Amount validator - required, must be valid positive number
  static Validator<dynamic> amount([
    String fieldName = 'Amount',
    AppLocalizations? loc,
  ]) {
    return _AmountValidator(
      fieldName: fieldName,
      required: true,
      allowZero: false,
      loc: loc,
    );
  }

  /// Amount validator - optional, if provided must be valid non-negative number
  static Validator<dynamic> amountOptional([
    String fieldName = 'Amount',
    AppLocalizations? loc,
  ]) {
    return _AmountValidator(
      fieldName: fieldName,
      required: false,
      allowZero: true,
      loc: loc,
    );
  }

  /// Amount validator - required, allows zero
  static Validator<dynamic> amountAllowZero([
    String fieldName = 'Amount',
    AppLocalizations? loc,
  ]) {
    return _AmountValidator(
      fieldName: fieldName,
      required: true,
      allowZero: true,
      loc: loc,
    );
  }

  /// Quantity validator - required positive number
  static Validator<dynamic> quantity([
    String fieldName = 'Quantity',
    AppLocalizations? loc,
  ]) {
    return _AmountValidator(
      fieldName: fieldName,
      required: true,
      allowZero: false,
      loc: loc,
    );
  }
}

/// Reusable amount validator for reactive_forms
class _AmountValidator extends Validator<dynamic> {
  final String fieldName;
  final bool required;
  final bool allowZero;
  final AppLocalizations? loc;

  _AmountValidator({
    this.fieldName = 'Amount',
    this.required = true,
    this.allowZero = false,
    this.loc,
  });

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final value = control.value as String?;

    if (value == null || value.isEmpty) {
      if (required) {
        if (loc == null) {
          return {'amount': '$fieldName is required'};
        }
        return {
          'amount': loc!.fieldIsRequired.replaceAll('{field}', fieldName),
        };
      }
      return null;
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      if (loc == null) {
        return {'amount': 'Please enter a valid $fieldName'};
      }
      return {'amount': loc!.invalidAmount};
    }

    if (!allowZero && amount <= 0) {
      if (loc == null) {
        return {'amount': '$fieldName must be greater than 0'};
      }
      return {'amount': loc!.amountMustBeGreaterThanZero};
    }

    if (allowZero && amount < 0) {
      if (loc == null) {
        return {'amount': '$fieldName cannot be negative'};
      }
      return {
        'amount': loc!.fieldCannotBeNegative.replaceAll('{field}', fieldName),
      };
    }

    return null;
  }
}
