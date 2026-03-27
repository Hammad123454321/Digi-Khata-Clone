import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enshaal_khata/core/database/app_database.dart';
import 'package:enshaal_khata/core/sync/sync_queue.dart';

void main() {
  test('SyncQueue enqueue and remove flow', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final queue = SyncQueue(appDatabase: db);

    final id = await queue.enqueue(
      entityType: 'customer',
      action: 'create',
      data: {'name': 'Test'},
    );

    final items = await queue.getQueue();
    expect(items.length, 1);
    expect(items.first['entity_type'], 'customer');

    await queue.removeById(id);
    final remaining = await queue.getQueue();
    expect(remaining, isEmpty);

    await db.close();
  });

  test('SyncQueue moves item to dead-letter after max retries', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final queue = SyncQueue(appDatabase: db);

    final id = await queue.enqueue(
      entityType: 'invoice',
      action: 'create',
      data: {'client_id': 'inv_local_1'},
    );

    await queue.incrementRetry(id, errorMessage: 'fail-1', maxRetries: 2);
    expect(await queue.getDeadLetterCount(), 0);

    await queue.incrementRetry(id, errorMessage: 'fail-2', maxRetries: 2);
    expect(await queue.getDeadLetterCount(), 1);
    expect(await queue.getQueueSize(), 0);

    await db.close();
  });

  test('SyncQueue can retry dead-letter items', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final queue = SyncQueue(appDatabase: db);

    final id = await queue.enqueue(
      entityType: 'customer',
      action: 'create',
      data: {'client_id': 'cust_local_1', 'name': 'Test'},
    );

    await queue.incrementRetry(id, errorMessage: 'dead', maxRetries: 1);
    expect(await queue.getDeadLetterCount(), 1);

    final restored = await queue.retryDeadLetters(limit: 10);
    expect(restored, 1);
    expect(await queue.getDeadLetterCount(), 0);
    expect(await queue.getQueueSize(), 1);

    await db.close();
  });
}
