// test/unit/database_helper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:contacto/data/database/database_helper.dart';
import 'package:contacto/data/models/contact.dart';

int _dbCounter = 0;

/// Opens a fresh in-memory SQLite database with a unique name so that no two
/// tests share the same connection.
Future<DatabaseHelper> _buildTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Each call gets a distinct URI so sqflite_ffi can't hand back a cached DB.
  final uniquePath = 'file:testdb_${_dbCounter++}?mode=memory&cache=shared';

  final db = await databaseFactoryFfi.openDatabase(
    uniquePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
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
      },
    ),
  );

  return DatabaseHelper.forTesting(db);
}

void main() {
  late DatabaseHelper db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseHelper.resetForTesting();
    db = await _buildTestDb();
  });

  // ── Registration ──────────────────────────────────────────────────────────

  group('User registration', () {
    test('isRegistered() returns false on a fresh DB', () async {
      expect(await db.isRegistered(), false);
    });

    test('setRegistered() marks user as registered', () async {
      await db.setRegistered();
      expect(await db.isRegistered(), true);
    });

    test('setRegistered() is idempotent', () async {
      await db.setRegistered();
      await db.setRegistered();
      expect(await db.isRegistered(), true);
    });
  });

  // ── Insert ────────────────────────────────────────────────────────────────

  group('insertContact()', () {
    test('returns a positive ID', () async {
      final id = await db.insertContact(
          Contact(name: 'Alice', phone: '0700000001', email: 'a@a.com'));
      expect(id, greaterThan(0));
    });

    test('contact appears in getAllContacts() after insert', () async {
      await db.insertContact(Contact(name: 'Bob'));
      final all = await db.getAllContacts();
      expect(all.any((c) => c.name == 'Bob'), true);
    });

    test('auto-assigns an id (not null)', () async {
      final id = await db.insertContact(Contact(name: 'Carol'));
      expect(id, isNotNull);
    });

    test('auto-sets created_at', () async {
      await db.insertContact(Contact(name: 'Dave'));
      final all = await db.getAllContacts();
      final dave = all.firstWhere((c) => c.name == 'Dave');
      expect(dave.createdAt, isNotNull);
      expect(dave.createdAt, isNotEmpty);
    });

    test('multiple inserts return unique IDs', () async {
      final id1 = await db.insertContact(Contact(name: 'Eve'));
      final id2 = await db.insertContact(Contact(name: 'Frank'));
      expect(id1, isNot(equals(id2)));
    });
  });

  // ── Read ──────────────────────────────────────────────────────────────────

  group('getAllContacts()', () {
    test('returns empty list on fresh DB', () async {
      expect(await db.getAllContacts(), isEmpty);
    });

    test('returns all inserted contacts', () async {
      await db.insertContact(Contact(name: 'Grace'));
      await db.insertContact(Contact(name: 'Hank'));
      final all = await db.getAllContacts();
      expect(all.length, 2);
    });

    test('contacts are sorted alphabetically by name', () async {
      await db.insertContact(Contact(name: 'Zara'));
      await db.insertContact(Contact(name: 'Aaron'));
      await db.insertContact(Contact(name: 'Moses'));
      final all = await db.getAllContacts();
      expect(all[0].name, 'Aaron');
      expect(all[1].name, 'Moses');
      expect(all[2].name, 'Zara');
    });
  });

  // ── Search ────────────────────────────────────────────────────────────────

  group('searchContacts()', () {
    setUp(() async {
      await db.insertContact(
          Contact(name: 'Naomi Auma', phone: '0711111111', email: 'naomi@test.com'));
      await db.insertContact(
          Contact(name: 'Peter Ouma', phone: '0722222222', email: 'peter@test.com'));
      await db.insertContact(
          Contact(name: 'Sandra Nambogo', phone: '0733333333', email: 'sandra@test.com'));
    });

    test('finds contact by exact name', () async {
      final results = await db.searchContacts('Naomi Auma');
      expect(results.length, 1);
      expect(results.first.name, 'Naomi Auma');
    });

    test('finds contact by partial name', () async {
      final results = await db.searchContacts('uma');
      expect(results.any((c) => c.name == 'Peter Ouma'), true);
    });

    test('finds contact by phone number', () async {
      final results = await db.searchContacts('0722222222');
      expect(results.length, 1);
      expect(results.first.name, 'Peter Ouma');
    });

    test('finds contact by email', () async {
      final results = await db.searchContacts('sandra@test.com');
      expect(results.length, 1);
      expect(results.first.name, 'Sandra Nambogo');
    });

    test('returns all matches for shared partial string', () async {
      final results = await db.searchContacts('Na');
      expect(results.length, greaterThanOrEqualTo(2));
    });

    test('returns empty list for non-existent query', () async {
      final results = await db.searchContacts('xyznotfound');
      expect(results, isEmpty);
    });

    test('search is case-insensitive (SQLite LIKE)', () async {
      final results = await db.searchContacts('naomi');
      expect(results.any((c) => c.name == 'Naomi Auma'), true);
    });
  });

  // ── Update ────────────────────────────────────────────────────────────────

  group('updateContact()', () {
    test('updated name is reflected in getAllContacts()', () async {
      final id = await db.insertContact(
          Contact(name: 'Old Name', phone: '0700000000'));
      final all = await db.getAllContacts();
      final inserted = all.firstWhere((c) => c.id == id);

      await db.updateContact(inserted.copyWith(name: 'New Name'));
      final updated = await db.getAllContacts();
      expect(updated.any((c) => c.name == 'New Name'), true);
      expect(updated.any((c) => c.name == 'Old Name'), false);
    });

    test('updating phone does not affect name', () async {
      final id =
          await db.insertContact(Contact(name: 'Stable Name', phone: '111'));
      final all = await db.getAllContacts();
      final contact = all.firstWhere((c) => c.id == id);

      await db.updateContact(contact.copyWith(phone: '999'));
      final updated = await db.getAllContacts();
      final result = updated.firstWhere((c) => c.id == id);
      expect(result.name, 'Stable Name');
      expect(result.phone, '999');
    });

    test('updating non-existent id affects 0 rows', () async {
      final contact = Contact(id: 99999, name: 'Ghost');
      final rowsAffected = await db.updateContact(contact);
      expect(rowsAffected, 0);
    });
  });

  // ── Delete ────────────────────────────────────────────────────────────────

  group('deleteContact()', () {
    test('deleted contact no longer appears in getAllContacts()', () async {
      final id =
          await db.insertContact(Contact(name: 'To Be Deleted'));
      await db.deleteContact(id);
      final all = await db.getAllContacts();
      expect(all.any((c) => c.id == id), false);
    });

    test('returns 1 when a contact is successfully deleted', () async {
      final id = await db.insertContact(Contact(name: 'Ephemeral'));
      final rowsAffected = await db.deleteContact(id);
      expect(rowsAffected, 1);
    });

    test('returns 0 when deleting a non-existent id', () async {
      final rowsAffected = await db.deleteContact(99999);
      expect(rowsAffected, 0);
    });

    test('deleting one contact does not affect others', () async {
      final id1 = await db.insertContact(Contact(name: 'Keep Me'));
      final id2 = await db.insertContact(Contact(name: 'Delete Me'));
      await db.deleteContact(id2);
      final all = await db.getAllContacts();
      expect(all.any((c) => c.id == id1), true);
      expect(all.any((c) => c.id == id2), false);
    });
  });

  // ── Full CRUD flow ────────────────────────────────────────────────────────

  group('Full CRUD lifecycle', () {
    test('insert → read → update → delete completes cleanly', () async {
      final id = await db.insertContact(
        Contact(name: 'Lifecycle Test', phone: '0700000099', email: 'lc@test.com'),
      );
      expect(id, greaterThan(0));

      var all = await db.getAllContacts();
      var contact = all.firstWhere((c) => c.id == id);
      expect(contact.name, 'Lifecycle Test');

      await db.updateContact(contact.copyWith(name: 'Updated Name', phone: '0799999999'));
      all = await db.getAllContacts();
      contact = all.firstWhere((c) => c.id == id);
      expect(contact.name, 'Updated Name');
      expect(contact.phone, '0799999999');

      await db.deleteContact(id);
      all = await db.getAllContacts();
      expect(all.any((c) => c.id == id), false);
    });
  });
}