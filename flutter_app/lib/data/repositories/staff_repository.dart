import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/sync/sync_queue.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/models/staff_model.dart';

/// Staff Repository
class StaffRepository {
  StaffRepository({
    required ApiClient apiClient,
    required AppDatabase appDatabase,
    required SyncQueue syncQueue,
  })  : _apiClient = apiClient,
        _appDatabase = appDatabase,
        _syncQueue = syncQueue;

  final ApiClient _apiClient;
  final AppDatabase _appDatabase;
  final SyncQueue _syncQueue;

  /// Create staff
  Future<Result<StaffModel>> createStaff({
    required String name,
    String? phone,
    String? email,
    String? role,
    String? address,
  }) async {
    if (name.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure('Staff name is required'),
      );
    }

    final payload = _buildCreatePayload(
      name: name,
      phone: phone,
      email: email,
      role: role,
      address: address,
    );
    try {
      final response = await _apiClient.post(
        ApiConstants.staff,
        data: payload,
      );

      final staff = _parseStaff(response.data);

      await _appDatabase.upsertStaffs([
        _staffCompanionFromModel(staff),
      ]);

      return Result.success(staff);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final staff = await _createStaffOffline(payload);
        return Result.success(staff);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return const Result.failure(
        UnknownFailure('Unable to save staff member. Please try again.'),
      );
    }
  }

  /// Get staff
  Future<Result<List<StaffModel>>> getStaff({
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    List<StaffModel> localStaff = const [];
    try {
      localStaff = await _loadLocalStaff(
        isActive: isActive,
        search: search,
        limit: limit,
        offset: offset,
      );
    } catch (_) {}

    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }
      if (search != null) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        ApiConstants.staff,
        queryParameters: queryParams,
      );

      final staff = _parseStaffList(response.data);

      await _appDatabase.upsertStaffs(
        staff.map(_staffCompanionFromModel).toList(),
      );

      final mergedLocal = await _loadLocalStaff(
        isActive: isActive,
        search: search,
        limit: limit,
        offset: offset,
      );

      if (mergedLocal.isNotEmpty) {
        return Result.success(mergedLocal);
      }

      return Result.success(staff);
    } on AppException catch (e) {
      if (localStaff.isNotEmpty ||
          e is NetworkException ||
          e is TimeoutException) {
        return Result.success(localStaff);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return Result.success(localStaff);
    }
  }

  /// Record salary
  Future<Result<void>> recordSalary({
    required String staffId,
    required String amount,
    required DateTime date,
    required String paymentMode,
    String? remarks,
  }) async {
    try {
      await _apiClient.post(
        '${ApiConstants.staff}/$staffId/salaries',
        data: {
          'staff_id': staffId,
          'amount': amount,
          'date': date.toIso8601String(),
          'payment_mode': paymentMode,
          if (remarks != null) 'remarks': remarks,
        },
      );

      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        await _createSalaryOffline(
          staffId: staffId,
          amount: amount,
          date: date,
          paymentMode: paymentMode,
          remarks: remarks,
        );
        return const Result.success(null);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(AppException exception) {
    return switch (exception) {
      NetworkException() => NetworkFailure(exception.message),
      ServerException() => ServerFailure(exception.message),
      TimeoutException() => TimeoutFailure(exception.message),
      ValidationException() => ValidationFailure(
          exception.message,
          exception.errors,
        ),
      _ => UnknownFailure(exception.message),
    };
  }

  Map<String, dynamic> _buildCreatePayload({
    required String name,
    String? phone,
    String? email,
    String? role,
    String? address,
  }) {
    final normalizedName = name.trim();
    final normalizedPhone = _nullableString(phone);
    final normalizedEmail = _nullableString(email);
    final normalizedRole = _nullableString(role);
    final normalizedAddress = _nullableString(address);

    return <String, dynamic>{
      'name': normalizedName,
      if (normalizedPhone != null) 'phone': normalizedPhone,
      if (normalizedEmail != null) 'email': normalizedEmail,
      if (normalizedRole != null) 'role': normalizedRole,
      if (normalizedAddress != null) 'address': normalizedAddress,
    };
  }

  List<StaffModel> _parseStaffList(dynamic data) {
    final list = _extractList(data);
    final result = <StaffModel>[];
    for (final raw in list) {
      try {
        result.add(_parseStaff(raw));
      } catch (_) {
        continue;
      }
    }
    return result;
  }

  StaffModel _parseStaff(dynamic data) {
    var map = _extractMap(data);
    if (map['data'] is Map) {
      map = Map<String, dynamic>.from(map['data'] as Map);
    } else if (map['staff'] is Map) {
      map = Map<String, dynamic>.from(map['staff'] as Map);
    }
    return StaffModel.fromJson(map);
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException('Invalid staff payload');
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;

    final map = _extractMap(data);
    final candidates = ['data', 'results', 'items', 'staff'];
    for (final key in candidates) {
      final value = map[key];
      if (value is List) {
        return value;
      }
    }

    throw const FormatException('Invalid staff list payload');
  }

  Future<List<StaffModel>> _loadLocalStaff({
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    final localRows = await _appDatabase.fetchStaffs(
      isActive: isActive,
      search: search,
      limit: limit,
      offset: offset,
    );
    return localRows.map(_staffFromRow).toList();
  }

  StaffModel _staffFromRow(Staff row) {
    return StaffModel(
      id: row.serverId ?? row.clientId ?? row.id.toString(),
      name: row.name,
      phone: row.phone,
      email: row.email,
      role: row.role,
      address: row.address,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  StaffsCompanion _staffCompanionFromModel(StaffModel model) {
    return StaffsCompanion(
      serverId: Value(model.id),
      name: Value(model.name),
      phone: Value(model.phone),
      email: Value(model.email),
      role: Value(model.role),
      address: Value(model.address),
      isActive: Value(model.isActive ?? true),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  Future<StaffModel> _createStaffOffline(
    Map<String, dynamic> payload,
  ) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final name = _requiredString(payload['name'], fieldName: 'name');
    final phone = _nullableString(payload['phone']);
    final email = _nullableString(payload['email']);
    final role = _nullableString(payload['role']);
    final address = _nullableString(payload['address']);

    final localId = await _appDatabase.into(_appDatabase.staffs).insert(
          StaffsCompanion.insert(
            name: name,
            clientId: Value(clientId),
            phone: Value(phone),
            email: Value(email),
            role: Value(role),
            address: Value(address),
            isActive: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
            isSynced: const Value(false),
            syncStatus: const Value('pending'),
          ),
        );

    await _syncQueue.enqueue(
      entityType: 'staff',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );

    return StaffModel(
      id: clientId,
      name: name,
      phone: phone,
      email: email,
      role: role,
      address: address,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _createSalaryOffline({
    required String staffId,
    required String amount,
    required DateTime date,
    required String paymentMode,
    String? remarks,
  }) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final staffName = await _resolveStaffName(staffId);
    final trimmedRemarks = remarks?.trim();
    final effectiveRemarks =
        (trimmedRemarks != null && trimmedRemarks.isNotEmpty)
            ? trimmedRemarks
            : (staffName != null ? 'Salary: $staffName' : null);

    String? referenceId;
    if (paymentMode == 'cash') {
      referenceId = await _createLocalCashSalaryTransaction(
        staffId: staffId,
        amount: amount,
        date: date,
        remarks: effectiveRemarks,
      );
    } else if (paymentMode == 'bank') {
      referenceId = await _createLocalBankSalaryTransaction(
        staffId: staffId,
        amount: amount,
        date: date,
        remarks: effectiveRemarks,
      );
    }

    final localId = await _appDatabase.into(_appDatabase.staffSalaries).insert(
          StaffSalariesCompanion.insert(
            clientId: Value(clientId),
            staffId: staffId,
            amount: amount,
            date: date,
            paymentMode: Value(paymentMode),
            remarks: Value(remarks),
            referenceId: Value(referenceId),
            referenceType: Value(paymentMode),
            createdAt: Value(now),
            isSynced: const Value(false),
            syncStatus: const Value('pending'),
          ),
        );

    await _syncQueue.enqueue(
      entityType: 'staff_salary',
      action: 'create',
      entityId: localId,
      data: {
        'staff_id': staffId,
        'amount': amount,
        'date': date.toIso8601String(),
        'payment_mode': paymentMode,
        if (remarks != null) 'remarks': remarks,
        'client_id': clientId,
        'updated_at': now.toIso8601String(),
      },
    );
  }

  Future<String?> _resolveStaffName(String staffId) async {
    final staff = await _appDatabase.findStaffByAnyId(staffId);
    return staff?.name;
  }

  Future<String?> _createLocalCashSalaryTransaction({
    required String staffId,
    required String amount,
    required DateTime date,
    String? remarks,
  }) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final normalizedDate = AppDateUtils.normalizeToStartOfDay(date);

    await _appDatabase.into(_appDatabase.cashTransactions).insert(
          CashTransactionsCompanion.insert(
            clientId: Value(clientId),
            transactionType: 'cash_out',
            amount: amount,
            date: normalizedDate,
            source: const Value('salary'),
            remarks: Value(remarks),
            referenceId: Value(staffId),
            referenceType: const Value('salary'),
            createdAt: Value(now),
            isSynced: const Value(false),
            syncStatus: const Value('pending'),
          ),
        );

    return clientId;
  }

  Future<String?> _createLocalBankSalaryTransaction({
    required String staffId,
    required String amount,
    required DateTime date,
    String? remarks,
  }) async {
    final accounts = await _appDatabase.fetchBankAccounts(
      isActive: true,
      limit: 1,
    );
    if (accounts.isEmpty) return null;

    final account = accounts.first;
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final accountId =
        account.serverId ?? account.clientId ?? account.id.toString();

    await _appDatabase.into(_appDatabase.bankTransactions).insert(
          BankTransactionsCompanion.insert(
            clientId: Value(clientId),
            accountId: accountId,
            transactionType: 'withdrawal',
            amount: amount,
            date: date,
            remarks: Value(remarks),
            createdAt: Value(now),
            isSynced: const Value(false),
            syncStatus: const Value('pending'),
          ),
        );

    await _applyLocalBankBalanceChange(
      account: account,
      transactionType: 'withdrawal',
      amount: amount,
    );

    return clientId;
  }

  Future<void> _applyLocalBankBalanceChange({
    required BankAccount account,
    required String transactionType,
    required String amount,
  }) async {
    final current = _parseAmount(account.currentBalance);
    final delta = _parseAmount(amount);
    final next = switch (transactionType) {
      'deposit' => current + delta,
      'withdrawal' => current - delta,
      _ => current,
    };

    final companion = BankAccountsCompanion(
      currentBalance: Value(_formatAmount(next)),
      updatedAt: Value(DateTime.now()),
      isSynced: const Value(false),
      syncStatus: const Value('pending'),
    );

    if (account.serverId != null) {
      await _appDatabase.updateBankAccountByServerId(
        serverId: account.serverId!,
        companion: companion,
      );
    } else if (account.clientId != null) {
      await _appDatabase.updateBankAccountByClientId(
        clientId: account.clientId!,
        companion: companion,
      );
    }
  }

  double _parseAmount(String? value) {
    return double.tryParse(value ?? '') ?? 0;
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(2);
  }

  String _requiredString(
    dynamic value, {
    required String fieldName,
  }) {
    final text = _nullableString(value);
    if (text == null) {
      throw FormatException('Missing required field: $fieldName');
    }
    return text;
  }

  String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
