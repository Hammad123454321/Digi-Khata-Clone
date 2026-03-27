import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:enshaal_khata/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Customer transaction invoice reference id can be remapped', () async {
    final db = AppDatabase(NativeDatabase.memory());

    await db.into(db.customerTransactions).insert(
          CustomerTransactionsCompanion.insert(
            clientId: const drift.Value('txn_local_1'),
            customerId: 'cust_1',
            transactionType: 'payment',
            amount: '100',
            date: DateTime.now(),
            referenceId: const drift.Value('inv_local_1'),
            referenceType: const drift.Value('invoice'),
            isSynced: const drift.Value(false),
            syncStatus: const drift.Value('pending'),
          ),
        );

    final updated = await db.updateCustomerTransactionsReferenceId(
      oldId: 'inv_local_1',
      newId: 'inv_server_1',
    );

    expect(updated, 1);
    final rows = await db.fetchCustomerTransactions(customerId: 'cust_1');
    expect(rows.single.referenceId, 'inv_server_1');

    await db.close();
  });
}
