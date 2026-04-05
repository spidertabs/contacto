// lib/data/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';

class DatabaseHelper {
  // Singleton for production use
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal() : _testDb = null;

  // Test constructor — accepts a pre-opened in-memory database
  DatabaseHelper.forTesting(Database testDb) : _testDb = testDb;

  final Database? _testDb;
  static Database? _db;

  Future<Database> get database async {
    if (_testDb != null) return _testDb!;
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacto.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        notes TEXT,
        created_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY,
        registered INTEGER DEFAULT 0
      )
    ''');
    await db.insert('user', {'id': 1, 'registered': 0});
  }

  // ── User / Registration ───────────────────────────────────────────────────

  Future<bool> isRegistered() async {
    final db = await database;
    final result = await db.query('user', where: 'id = ?', whereArgs: [1]);
    if (result.isEmpty) return false;
    return (result.first['registered'] as int) == 1;
  }

  Future<void> setRegistered() async {
    final db = await database;
    await db.update('user', {'registered': 1},
        where: 'id = ?', whereArgs: [1]);
  }

  // ── Contacts CRUD ─────────────────────────────────────────────────────────

  Future<int> insertContact(Contact contact) async {
    final db = await database;
    final map = contact.toMap()..remove('id');
    map['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('contacts', map);
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final result = await db.query('contacts', orderBy: 'name ASC');
    return result.map((map) => Contact.fromMap(map)).toList();
  }

  Future<List<Contact>> searchContacts(String query) async {
    final db = await database;
    final result = await db.query(
      'contacts',
      where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((map) => Contact.fromMap(map)).toList();
  }

  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update('contacts', contact.toMap(),
        where: 'id = ?', whereArgs: [contact.id]);
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> closeDB() async {
    if (_testDb != null) return; // Don't close injected test DBs
    final db = await database;
    await db.close();
    _db = null;
  }

  // ── Testing helpers ───────────────────────────────────────────────────────

  /// Resets the singleton DB reference between tests.
  /// Call this in setUp() when using DatabaseHelper.forTesting().
  static void resetForTesting() {
    _db = null;
  }
}