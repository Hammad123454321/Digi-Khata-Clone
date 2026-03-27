import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Local SQLite database for offline storage
class LocalDatabase {
  static LocalDatabase? _instance;
  static Database? _database;
  static Future<Database>? _databaseFuture;

  LocalDatabase._internal();

  factory LocalDatabase() {
    _instance ??= LocalDatabase._internal();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Thread-safe initialization using Future
    _databaseFuture ??= _initDatabase();
    _database = await _databaseFuture;
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'digikhata_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Cash Transactions
    await db.execute('''
      CREATE TABLE cash_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        business_id INTEGER NOT NULL,
        transaction_type TEXT NOT NULL,
        amount TEXT NOT NULL,
        date TEXT NOT NULL,
        source TEXT,
        remarks TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(server_id)
      )
    ''');

    // Stock Items
    await db.execute('''
      CREATE TABLE stock_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        purchase_price TEXT NOT NULL,
        sale_price TEXT NOT NULL,
        unit TEXT NOT NULL,
        opening_stock TEXT NOT NULL,
        current_stock TEXT NOT NULL,
        description TEXT,
        is_active INTEGER DEFAULT 1,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(server_id)
      )
    ''');

    // Inventory Transactions
    await db.execute('''
      CREATE TABLE inventory_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        business_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        transaction_type TEXT NOT NULL,
        quantity TEXT NOT NULL,
        reference_number TEXT,
        remarks TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(server_id)
      )
    ''');

    // Customers
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        balance TEXT DEFAULT '0',
        is_active INTEGER DEFAULT 1,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(server_id)
      )
    ''');

    // Suppliers
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        balance TEXT DEFAULT '0',
        is_active INTEGER DEFAULT 1,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(server_id)
      )
    ''');

    // Invoices
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        business_id INTEGER NOT NULL,
        customer_id INTEGER,
        invoice_number TEXT,
        invoice_type TEXT NOT NULL,
        date TEXT NOT NULL,
        subtotal TEXT NOT NULL,
        tax_amount TEXT NOT NULL,
        discount_amount TEXT NOT NULL,
        total_amount TEXT NOT NULL,
        paid_amount TEXT DEFAULT '0',
        remarks TEXT,
        pdf_path TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(server_id)
      )
    ''');

    // Invoice Items
    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        invoice_id INTEGER NOT NULL,
        item_id INTEGER,
        item_name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        unit_price TEXT NOT NULL,
        total_price TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(server_id),
        FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
      )
    ''');

    // Expenses
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        business_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount TEXT NOT NULL,
        date TEXT NOT NULL,
        payment_mode TEXT NOT NULL,
        description TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(server_id)
      )
    ''');

    // Expense Categories
    await db.execute('''
      CREATE TABLE expense_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(server_id)
      )
    ''');

    // Staff
    await db.execute('''
      CREATE TABLE staff (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        role TEXT,
        address TEXT,
        is_active INTEGER DEFAULT 1,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(server_id)
      )
    ''');

    // Bank Accounts
    await db.execute('''
      CREATE TABLE bank_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        business_id INTEGER NOT NULL,
        bank_name TEXT NOT NULL,
        account_number TEXT NOT NULL,
        account_holder_name TEXT,
        branch TEXT,
        ifsc_code TEXT,
        account_type TEXT,
        opening_balance TEXT NOT NULL,
        current_balance TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        is_synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(server_id)
      )
    ''');

    // Sync Queue
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id INTEGER,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        error_message TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute(
        'CREATE INDEX idx_cash_transactions_business ON cash_transactions(business_id)');
    await db.execute(
        'CREATE INDEX idx_cash_transactions_synced ON cash_transactions(is_synced)');
    await db.execute(
        'CREATE INDEX idx_stock_items_business ON stock_items(business_id)');
    await db
        .execute('CREATE INDEX idx_invoices_business ON invoices(business_id)');
    await db.execute(
        'CREATE INDEX idx_customers_business ON customers(business_id)');
    await db.execute(
        'CREATE INDEX idx_suppliers_business ON suppliers(business_id)');
    await db.execute(
        'CREATE INDEX idx_sync_queue_created ON sync_queue(created_at)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Add migration logic
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
