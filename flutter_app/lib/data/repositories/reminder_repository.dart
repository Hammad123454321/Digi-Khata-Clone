import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/sync/sync_queue.dart';

/// Reminder Repository
class ReminderRepository {
  ReminderRepository({
    required ApiClient apiClient,
    required AppDatabase appDatabase,
    required SyncQueue syncQueue,
  })  : _apiClient = apiClient,
        _appDatabase = appDatabase,
        _syncQueue = syncQueue;

  final ApiClient _apiClient;
  final AppDatabase _appDatabase;
  final SyncQueue _syncQueue;

  Future<Result<List<Map<String, dynamic>>>> getReminders({
    String? entityType,
    int limit = 200,
    int offset = 0,
  }) async {
    List<Map<String, dynamic>> localReminders = [];
    try {
      final localRows = await _appDatabase.fetchReminders(
        entityType: entityType,
        limit: limit,
        offset: offset,
      );
      localReminders = localRows.map(_reminderRowToMap).toList();
    } catch (_) {}

    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (entityType != null) {
        queryParams['entity_type'] = entityType;
      }

      final response = await _apiClient.get(
        ApiConstants.reminders,
        queryParameters: queryParams,
      );

      final reminders = (response.data as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      await _appDatabase.upsertReminders(
        reminders.map(_reminderCompanionFromJson).toList(),
      );

      return Result.success(reminders);
    } on AppException catch (e) {
      if (localReminders.isNotEmpty ||
          e is NetworkException ||
          e is TimeoutException) {
        return Result.success(localReminders);
      }
      return Result.failure(_mapExceptionToFailure(e));
    } catch (e) {
      return Result.success(localReminders);
    }
  }

  Future<Result<void>> createReminder({
    required String entityType,
    required String entityId,
    required double amount,
    DateTime? dueDate,
    String? message,
    bool sendSms = false,
    String? entityName,
    String? entityPhone,
  }) async {
    final payload = <String, dynamic>{
      'entity_type': entityType,
      'entity_id': entityId,
      'amount': amount,
      if (dueDate != null) 'due_date': dueDate.toIso8601String(),
      if (message != null && message.isNotEmpty) 'message': message,
      'send_sms': sendSms,
    };

    try {
      final response = await _apiClient.post(
        ApiConstants.reminders,
        data: payload,
      );

      final reminder = Map<String, dynamic>.from(
        response.data as Map,
      );

      await _appDatabase.upsertReminders([
        _reminderCompanionFromJson(reminder),
      ]);

      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        await _createReminderOffline(
          payload: payload,
          entityName: entityName,
          entityPhone: entityPhone,
        );
        return const Result.success(null);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  Future<Result<void>> resolveReminder(String reminderId) async {
    try {
      await _apiClient.post('${ApiConstants.reminders}/$reminderId/resolve');

      await _markReminderResolved(
        reminderId: reminderId,
        isSynced: true,
      );

      return const Result.success(null);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        await _resolveReminderOffline(reminderId);
        return const Result.success(null);
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  Future<Result<void>> sendReminderSms(String reminderId) async {
    try {
      await _apiClient.post('${ApiConstants.reminders}/$reminderId/send');
      return const Result.success(null);
    } on AppException catch (e) {
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

  RemindersCompanion _reminderCompanionFromJson(Map<String, dynamic> json) {
    final serverId = json['id']?.toString();
    return RemindersCompanion(
      serverId: Value(serverId),
      entityType: Value(json['entity_type']?.toString() ?? ''),
      entityId: Value(json['entity_id']?.toString() ?? ''),
      entityDisplayName: Value(json['entity_name']?.toString()),
      entityPhone: Value(json['entity_phone']?.toString()),
      amount: Value(json['amount']?.toString() ?? '0'),
      dueDate: Value(_parseDate(json['due_date'])),
      message: Value(json['message']?.toString()),
      isResolved: Value((json['is_resolved'] as bool?) ?? false),
      resolvedAt: Value(_parseDate(json['resolved_at'])),
      createdAt: Value(_parseDate(json['created_at'])),
      updatedAt: Value(_parseDate(json['updated_at'])),
      isSynced: const Value(true),
      syncStatus: const Value('synced'),
    );
  }

  Map<String, dynamic> _reminderRowToMap(Reminder row) {
    return {
      'id': row.serverId ?? row.clientId ?? row.id.toString(),
      'entity_type': row.entityType,
      'entity_id': row.entityId,
      if (row.entityDisplayName != null) 'entity_name': row.entityDisplayName,
      if (row.entityPhone != null) 'entity_phone': row.entityPhone,
      'amount': row.amount,
      if (row.dueDate != null) 'due_date': row.dueDate!.toIso8601String(),
      if (row.message != null) 'message': row.message,
      'is_resolved': row.isResolved,
      if (row.resolvedAt != null)
        'resolved_at': row.resolvedAt!.toIso8601String(),
      if (row.createdAt != null) 'created_at': row.createdAt!.toIso8601String(),
    };
  }

  Future<void> _createReminderOffline({
    required Map<String, dynamic> payload,
    String? entityName,
    String? entityPhone,
  }) async {
    final now = DateTime.now();
    final clientId = const Uuid().v4();
    final dueDate = _parseDate(payload['due_date']);

    final localId = await _appDatabase.into(_appDatabase.reminders).insert(
          RemindersCompanion.insert(
            clientId: Value(clientId),
            entityType: payload['entity_type']?.toString() ?? '',
            entityId: payload['entity_id']?.toString() ?? '',
            entityDisplayName: Value(entityName),
            entityPhone: Value(entityPhone),
            amount: payload['amount']?.toString() ?? '0',
            dueDate: Value(dueDate),
            message: Value(payload['message']?.toString()),
            isResolved: const Value(false),
            createdAt: Value(now),
            updatedAt: Value(now),
            isSynced: const Value(false),
            syncStatus: const Value('pending'),
          ),
        );

    await _syncQueue.enqueue(
      entityType: 'reminder',
      action: 'create',
      entityId: localId,
      data: {
        ...payload,
        'client_id': clientId,
        if (entityName != null) 'entity_name': entityName,
        if (entityPhone != null) 'entity_phone': entityPhone,
        'updated_at': now.toIso8601String(),
      },
    );
  }

  Future<void> _resolveReminderOffline(String reminderId) async {
    final reminder = await _appDatabase.findReminderByAnyId(reminderId);
    final resolvedAt = DateTime.now();

    if (reminder != null) {
      final companion = RemindersCompanion(
        isResolved: const Value(true),
        resolvedAt: Value(resolvedAt),
        updatedAt: Value(resolvedAt),
        isSynced: const Value(false),
        syncStatus: const Value('pending'),
      );

      if (reminder.serverId != null) {
        await _appDatabase.updateReminderByServerId(
          serverId: reminder.serverId!,
          companion: companion,
        );
      } else if (reminder.clientId != null) {
        await _appDatabase.updateReminderByClientId(
          clientId: reminder.clientId!,
          companion: companion,
        );
      }
    }

    await _syncQueue.enqueue(
      entityType: 'reminder',
      action: 'resolve',
      data: {
        'id': reminder?.serverId ?? reminderId,
        if (reminder?.clientId != null) 'client_id': reminder!.clientId,
        'resolved_at': resolvedAt.toIso8601String(),
        'updated_at': resolvedAt.toIso8601String(),
      },
    );
  }

  Future<void> _markReminderResolved({
    required String reminderId,
    required bool isSynced,
  }) async {
    final resolvedAt = DateTime.now();
    final companion = RemindersCompanion(
      isResolved: const Value(true),
      resolvedAt: Value(resolvedAt),
      updatedAt: Value(resolvedAt),
      isSynced: Value(isSynced),
      syncStatus: Value(isSynced ? 'synced' : 'pending'),
    );

    final updated = await _appDatabase.updateReminderByServerId(
      serverId: reminderId,
      companion: companion,
    );

    if (updated == 0) {
      final local = await _appDatabase.findReminderByAnyId(reminderId);
      if (local?.clientId != null) {
        await _appDatabase.updateReminderByClientId(
          clientId: local!.clientId!,
          companion: companion,
        );
      }
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
