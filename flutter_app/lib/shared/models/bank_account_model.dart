import 'package:equatable/equatable.dart';

/// Bank Account Model
class BankAccountModel extends Equatable {
  const BankAccountModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    this.accountHolderName,
    this.branch,
    this.ifscCode,
    this.accountType,
    required this.openingBalance,
    required this.currentBalance,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String bankName;
  final String accountNumber;
  final String? accountHolderName;
  final String? branch;
  final String? ifscCode;
  final String? accountType;
  final String openingBalance;
  final String currentBalance;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'].toString(),
      bankName: json['bank_name'] as String,
      accountNumber: json['account_number'] as String,
      accountHolderName: json['account_holder_name'] as String?,
      branch: json['branch'] as String?,
      ifscCode: json['ifsc_code'] as String?,
      accountType: json['account_type'] as String?,
      openingBalance: json['opening_balance'] as String,
      currentBalance: json['current_balance'] as String,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_name': bankName,
      'account_number': accountNumber,
      if (accountHolderName != null) 'account_holder_name': accountHolderName,
      if (branch != null) 'branch': branch,
      if (ifscCode != null) 'ifsc_code': ifscCode,
      if (accountType != null) 'account_type': accountType,
      'opening_balance': openingBalance,
    };
  }

  @override
  List<Object?> get props => [
        id,
        bankName,
        accountNumber,
        accountHolderName,
        branch,
        ifscCode,
        accountType,
        openingBalance,
        currentBalance,
        isActive,
        createdAt,
        updatedAt,
      ];
}
