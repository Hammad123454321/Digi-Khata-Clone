import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../storage/secure_storage_service.dart';

/// Sync Queue for offline changes (using SQLite for better performance)
class SyncQueue {
  SyncQueue({
    required AppDatabase appDatabase,
    SecureStorageService? secureStorage,
  })  : _appDatabase = appDatabase,
        _secureStorage = secureStorage;

  final AppDatabase _appDatabase;
  final SecureStorageService? _secureStorage;
  static const int _defaultMaxRetries = 8;

  /// Add change to queue (using SQLite)
  Future<int> enqueue({
    required String entityType,
    required String action,
    required Map<String, dynamic> data,
    int? entityId,
    String? entityServerId,
  }) async {
    final scopedData = Map<String, dynamic>.from(data);
    final businessId = await _secureStorage?.getBusinessId();
    if (businessId != null &&
        businessId.isNotEmpty &&
        !scopedData.containsKey('business_id')) {
      scopedData['business_id'] = businessId;
    }

    return _appDatabase.into(_appDatabase.syncQueueEntries).insert(
          SyncQueueEntriesCompanion.insert(
            entityType: entityType,
            action: action,
            payload: jsonEncode(scopedData),
            entityLocalId: Value(entityId),
            entityServerId: Value(entityServerId),
          ),
        );
  }

  /// Get all queued changes (from SQLite)
  Future<List<Map<String, dynamic>>> getQueue({
    int? limit,
    bool includeDeferred = false,
  }) async {
    final now = DateTime.now();
    final query = _appDatabase.select(_appDatabase.syncQueueEntries)
      ..where((tbl) => tbl.isDeadLetter.equals(false));
    if (!includeDeferred) {
      query.where(
        (tbl) =>
            tbl.nextAttemptAt.isNull() |
            tbl.nextAttemptAt.isSmallerOrEqualValue(now),
      );
    }
    query
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.asc),
      ]);
    if (limit != null) {
      query.limit(limit);
    }
    final results = await query.get();

    return results.map((row) {
      final data = jsonDecode(row.payload) as Map<String, dynamic>;
      return {
        'id': row.id,
        'entity_type': row.entityType,
        'entity_id': row.entityServerId ?? row.entityLocalId?.toString(),
        'entity_local_id': row.entityLocalId,
        'entity_server_id': row.entityServerId,
        'action': row.action,
        'data': data,
        'retry_count': row.retryCount,
        'last_error': row.lastError,
        'last_attempt_at': row.lastAttemptAt?.toIso8601String(),
        'next_attempt_at': row.nextAttemptAt?.toIso8601String(),
        'is_dead_letter': row.isDeadLetter,
        'created_at': row.createdAt.toIso8601String(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getDeadLetterQueue({int? limit}) async {
    final query = _appDatabase.select(_appDatabase.syncQueueEntries)
      ..where((tbl) => tbl.isDeadLetter.equals(true))
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.asc),
      ]);
    if (limit != null) {
      query.limit(limit);
    }
    final rows = await query.get();
    return rows.map((row) {
      final data = jsonDecode(row.payload) as Map<String, dynamic>;
      return {
        'id': row.id,
        'entity_type': row.entityType,
        'entity_id': row.entityServerId ?? row.entityLocalId?.toString(),
        'action': row.action,
        'data': data,
        'retry_count': row.retryCount,
        'last_error': row.lastError,
        'last_attempt_at': row.lastAttemptAt?.toIso8601String(),
        'created_at': row.createdAt.toIso8601String(),
      };
    }).toList();
  }

  /// Remove changes from queue by IDs
  Future<void> dequeue(List<int> ids) async {
    await (_appDatabase.delete(_appDatabase.syncQueueEntries)
          ..where((tbl) => tbl.id.isIn(ids)))
        .go();
  }

  /// Remove single change from queue by ID
  Future<void> removeById(int id) async {
    await (_appDatabase.delete(_appDatabase.syncQueueEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<void> removeByEntity({
    required String entityType,
    required String entityId,
  }) async {
    final localId = int.tryParse(entityId);
    await (_appDatabase.delete(_appDatabase.syncQueueEntries)
          ..where(
            (tbl) => tbl.entityType.equals(entityType),
          )
          ..where(
            (tbl) => localId == null
                ? tbl.entityServerId.equals(entityId)
                : (tbl.entityServerId.equals(entityId) |
                    tbl.entityLocalId.equals(localId)),
          ))
        .go();
  }

  /// Clear queue
  Future<void> clear() async {
    await _appDatabase.delete(_appDatabase.syncQueueEntries).go();
  }

  Future<void> removePendingCreateByClientId(String clientId) async {
    await (_appDatabase.delete(_appDatabase.syncQueueEntries)
          ..where(
            (tbl) =>
                tbl.entityType.equals('customer') &
                tbl.action.equals('create') &
                tbl.payload.like('%"client_id":"$clientId"%'),
          ))
        .go();
  }

  Future<void> removePendingCreateByClientIdForEntity({
    required String entityType,
    required String clientId,
  }) async {
    await (_appDatabase.delete(_appDatabase.syncQueueEntries)
          ..where(
            (tbl) =>
                tbl.entityType.equals(entityType) &
                tbl.action.equals('create') &
                tbl.payload.like('%"client_id":"$clientId"%'),
          ))
        .go();
  }

  Future<void> mergePendingCreatePayload({
    required String entityType,
    required String clientId,
    required Map<String, dynamic> updates,
  }) async {
    final query = _appDatabase.select(_appDatabase.syncQueueEntries)
      ..where(
        (tbl) =>
            tbl.entityType.equals(entityType) &
            tbl.action.equals('create') &
            tbl.payload.like('%"client_id":"$clientId"%'),
      );
    final entries = await query.get();
    if (entries.isEmpty) return;

    for (final entry in entries) {
      final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
      payload.addAll(updates);
      await (_appDatabase.update(_appDatabase.syncQueueEntries)
            ..where((tbl) => tbl.id.equals(entry.id)))
          .write(
        SyncQueueEntriesCompanion(
          payload: Value(jsonEncode(payload)),
        ),
      );
    }
  }

  /// Get queue size
  Future<int> getQueueSize() async {
    final countExp = _appDatabase.syncQueueEntries.id.count();
    final query = _appDatabase.selectOnly(_appDatabase.syncQueueEntries)
      ..where(_appDatabase.syncQueueEntries.isDeadLetter.equals(false))
      ..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<int> getDeadLetterCount() async {
    final countExp = _appDatabase.syncQueueEntries.id.count();
    final query = _appDatabase.selectOnly(_appDatabase.syncQueueEntries)
      ..where(_appDatabase.syncQueueEntries.isDeadLetter.equals(true))
      ..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<void> markAttempted(int id) async {
    await (_appDatabase.update(_appDatabase.syncQueueEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      SyncQueueEntriesCompanion(
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }

  /// Increment retry count for failed sync
  Future<void> incrementRetry(
    int id, {
    String? errorMessage,
    int maxRetries = _defaultMaxRetries,
  }) async {
    final entry = await (_appDatabase.select(_appDatabase.syncQueueEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (entry == null) return;

    final now = DateTime.now();
    final nextRetryCount = entry.retryCount + 1;
    final shouldDeadLetter = nextRetryCount >= maxRetries;
    DateTime? nextAttempt;
    if (!shouldDeadLetter) {
      final exponent = nextRetryCount - 1;
      final maxExponent = exponent > 10 ? 10 : exponent;
      final backoffSeconds = 15 * (1 << maxExponent);
      final boundedSeconds =
          backoffSeconds > 6 * 60 * 60 ? 6 * 60 * 60 : backoffSeconds;
      nextAttempt = now.add(Duration(seconds: boundedSeconds));
    }

    await (_appDatabase.update(_appDatabase.syncQueueEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      SyncQueueEntriesCompanion(
        retryCount: Value(nextRetryCount),
        lastError: Value(errorMessage),
        lastAttemptAt: Value(now),
        nextAttemptAt: Value(nextAttempt),
        isDeadLetter: Value(shouldDeadLetter),
      ),
    );
  }

  Future<int> retryDeadLetters({int limit = 50}) async {
    final query = _appDatabase.select(_appDatabase.syncQueueEntries)
      ..where((tbl) => tbl.isDeadLetter.equals(true))
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.asc),
      ])
      ..limit(limit);
    final rows = await query.get();
    if (rows.isEmpty) return 0;

    final now = DateTime.now();
    for (final row in rows) {
      await (_appDatabase.update(_appDatabase.syncQueueEntries)
            ..where((tbl) => tbl.id.equals(row.id)))
          .write(
        SyncQueueEntriesCompanion(
          retryCount: const Value(0),
          lastError: const Value(null),
          nextAttemptAt: Value(now),
          isDeadLetter: const Value(false),
        ),
      );
    }
    return rows.length;
  }

  Future<int> retryDeadLettersForEntity({
    required String entityType,
    required String entityId,
  }) async {
    final localId = int.tryParse(entityId);
    final query = _appDatabase.select(_appDatabase.syncQueueEntries)
      ..where((tbl) => tbl.isDeadLetter.equals(true))
      ..where((tbl) => tbl.entityType.equals(entityType))
      ..where(
        (tbl) => localId == null
            ? tbl.entityServerId.equals(entityId)
            : (tbl.entityServerId.equals(entityId) |
                tbl.entityLocalId.equals(localId)),
      );
    final rows = await query.get();
    if (rows.isEmpty) return 0;

    final now = DateTime.now();
    for (final row in rows) {
      await (_appDatabase.update(_appDatabase.syncQueueEntries)
            ..where((tbl) => tbl.id.equals(row.id)))
          .write(
        SyncQueueEntriesCompanion(
          retryCount: const Value(0),
          lastError: const Value(null),
          nextAttemptAt: Value(now),
          isDeadLetter: const Value(false),
        ),
      );
    }
    return rows.length;
  }
}
