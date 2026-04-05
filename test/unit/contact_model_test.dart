import 'package:flutter_test/flutter_test.dart';
import 'package:contacto/data/models/contact.dart';

void main() {
  group('Contact.toMap()', () {
    test('includes all fields', () {
      final c = Contact(
        id: 1,
        name: 'Jane Doe',
        phone: '0712345678',
        email: 'jane@example.com',
        notes: 'Met at conference',
      );
      final map = c.toMap();
      expect(map['id'], 1);
      expect(map['name'], 'Jane Doe');
      expect(map['phone'], '0712345678');
      expect(map['email'], 'jane@example.com');
      expect(map['notes'], 'Met at conference');
    });

    test('replaces null phone/email/notes with empty string', () {
      final c = Contact(name: 'Solo');
      final map = c.toMap();
      expect(map['phone'], '');
      expect(map['email'], '');
      expect(map['notes'], '');
    });

    test('sets created_at when not provided', () {
      final c = Contact(name: 'AutoDate');
      final map = c.toMap();
      expect(map['created_at'], isNotNull);
      expect(map['created_at'], isA<String>());
    });
  });

  group('Contact.fromMap()', () {
    test('reconstructs a Contact correctly', () {
      final map = {
        'id': 2,
        'name': 'John Smith',
        'phone': '0798765432',
        'email': 'john@example.com',
        'notes': '',
        'created_at': '2024-01-01T00:00:00.000',
      };
      final c = Contact.fromMap(map);
      expect(c.id, 2);
      expect(c.name, 'John Smith');
      expect(c.phone, '0798765432');
      expect(c.email, 'john@example.com');
      expect(c.createdAt, '2024-01-01T00:00:00.000');
    });

    test('roundtrip: toMap → fromMap preserves all data', () {
      final original = Contact(
        id: 5,
        name: 'Roundtrip User',
        phone: '0700000000',
        email: 'rt@test.com',
        notes: 'note',
      );
      final roundTripped = Contact.fromMap(original.toMap());
      expect(roundTripped.name, original.name);
      expect(roundTripped.phone, original.phone);
      expect(roundTripped.email, original.email);
      expect(roundTripped.notes, original.notes);
    });
  });

  group('Contact.copyWith()', () {
    test('updates only specified fields', () {
      final original = Contact(id: 1, name: 'Alice', phone: '111');
      final updated = original.copyWith(phone: '999');
      expect(updated.id, 1);
      expect(updated.name, 'Alice');
      expect(updated.phone, '999');
    });

    test('does not mutate the original', () {
      final original = Contact(id: 1, name: 'Alice', phone: '111');
      original.copyWith(phone: '999');
      expect(original.phone, '111');
    });

    test('can update every field at once', () {
      final original = Contact(id: 1, name: 'A', phone: '1', email: 'a@a.com');
      final updated = original.copyWith(
          id: 2, name: 'B', phone: '2', email: 'b@b.com', notes: 'new');
      expect(updated.id, 2);
      expect(updated.name, 'B');
      expect(updated.phone, '2');
      expect(updated.email, 'b@b.com');
      expect(updated.notes, 'new');
    });
  });

  group('Contact.initials', () {
    test('two-part name returns two initials', () {
      expect(Contact(name: 'Mary Wanjiku').initials, 'MW');
    });

    test('single name returns one initial', () {
      expect(Contact(name: 'Moses').initials, 'M');
    });

    test('empty name returns ?', () {
      expect(Contact(name: '').initials, '?');
    });

    test('initials are always uppercase', () {
      expect(Contact(name: 'alice bob').initials, 'AB');
    });

    test('extra spaces are handled gracefully', () {
      expect(Contact(name: '  ').initials, '?');
    });

    test('three-part name uses only first two parts', () {
      expect(Contact(name: 'John Paul Jones').initials, 'JP');
    });
  });
}
