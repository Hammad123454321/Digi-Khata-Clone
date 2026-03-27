import 'package:sqflite/sqflite.dart';
import '../di/injection.dart';
import '../database/local_database.dart';

/// Base class for local repositories
abstract class LocalRepositoryBase {
  LocalDatabase get _localDatabase => getIt<LocalDatabase>();

  Future<Database> get db => _localDatabase.database;

  /// Convert map to entity (implemented by subclasses)
  T fromMap<T>(Map<String, dynamic> map);

  /// Convert entity to map (implemented by subclasses)
  Map<String, dynamic> toMap<T>(T entity);

  /// Insert entity locally
  Future<int> insertLocal<T>({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final database = await db;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();
    data['is_synced'] = 0;
    data['sync_status'] = 'pending';
    return await database.insert(table, data);
  }

  /// Update entity locally
  Future<int> updateLocal<T>({
    required String table,
    required Map<String, dynamic> data,
    required int localId,
  }) async {
    final database = await db;
    data['updated_at'] = DateTime.now().toIso8601String();
    data['is_synced'] = 0;
    data['sync_status'] = 'pending';
    return await database.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Delete entity locally
  Future<int> deleteLocal({
    required String table,
    required int localId,
  }) async {
    final database = await db;
    return await database.delete(
      table,
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Get all entities from local database
  Future<List<Map<String, dynamic>>> getAllLocal({
    required String table,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final database = await db;
    return await database.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// Get entity by local ID
  Future<Map<String, dynamic>?> getLocalById({
    required String table,
    required int localId,
  }) async {
    final database = await db;
    final results = await database.query(
      table,
      where: 'id = ?',
      whereArgs: [localId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get pending sync items
  Future<List<Map<String, dynamic>>> getPendingSync({
    required String table,
  }) async {
    final database = await db;
    return await database.query(
      table,
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
  }

  /// Mark entity as synced
  Future<void> markAsSynced({
    required String table,
    required int localId,
    int? serverId,
  }) async {
    final database = await db;
    await database.update(
      table,
      {
        'is_synced': 1,
        'sync_status': 'synced',
        'updated_at': DateTime.now().toIso8601String(),
        if (serverId != null) 'server_id': serverId,
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Sync entity from server (upsert)
  Future<void> syncFromServer({
    required String table,
    required Map<String, dynamic> data,
    int? serverId,
  }) async {
    final database = await db;

    if (serverId != null) {
      // Check if exists by server_id
      final existing = await database.query(
        table,
        where: 'server_id = ?',
        whereArgs: [serverId],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        // Update existing
        await database.update(
          table,
          {
            ...data,
            'is_synced': 1,
            'sync_status': 'synced',
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'server_id = ?',
          whereArgs: [serverId],
        );
      } else {
        // Insert new
        await database.insert(
          table,
          {
            ...data,
            'server_id': serverId,
            'is_synced': 1,
            'sync_status': 'synced',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      }
    } else {
      // Insert as new local record
      await insertLocal(table: table, data: data);
    }
  }
}
