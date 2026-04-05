import 'package:flutter_test/flutter_test.dart';

// Mirrors the validation regexes used in AddContactScreen / EditContactScreen
bool isValidPhone(String phone) =>
    RegExp(r'^[0-9+\s\-()]+$').hasMatch(phone);

bool isValidEmail(String email) =>
    RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

bool isValidName(String name) => name.trim().isNotEmpty;

void main() {
  group('Phone validation', () {
    test('local Uganda format passes', () {
      expect(isValidPhone('0712345678'), true);
    });

    test('international format with + passes', () {
      expect(isValidPhone('+254712345678'), true);
    });

    test('number with spaces passes', () {
      expect(isValidPhone('0712 345 678'), true);
    });

    test('number with dashes passes', () {
      expect(isValidPhone('0712-345-678'), true);
    });

    test('number with parentheses passes', () {
      expect(isValidPhone('(256) 700-000000'), true);
    });

    test('letters in phone number fail', () {
      expect(isValidPhone('abc-phone'), false);
    });

    test('email-like string fails', () {
      expect(isValidPhone('john@number'), false);
    });

    test('completely empty string fails', () {
      expect(isValidPhone(''), false);
    });
  });

  group('Email validation', () {
    test('standard email passes', () {
      expect(isValidEmail('user@example.com'), true);
    });

    test('email with dots and plus passes', () {
      expect(isValidEmail('user.name+tag@domain.co.ug'), true);
    });

    test('subdomain email passes', () {
      expect(isValidEmail('admin@mail.server.org'), true);
    });

    test('missing @ fails', () {
      expect(isValidEmail('notanemail'), false);
    });

    test('missing TLD fails', () {
      expect(isValidEmail('missing@domain'), false);
    });

    test('@ at start fails', () {
      expect(isValidEmail('@nodomain.com'), false);
    });

    test('empty string fails', () {
      expect(isValidEmail(''), false);
    });
  });

  group('Name validation', () {
    test('non-empty name passes', () {
      expect(isValidName('Naomi'), true);
    });

    test('multi-word name passes', () {
      expect(isValidName('John Paul Jones'), true);
    });

    test('empty string fails', () {
      expect(isValidName(''), false);
    });

    test('whitespace-only string fails', () {
      expect(isValidName('   '), false);
    });

    test('name with leading/trailing spaces passes (trimmed)', () {
      expect(isValidName('  Alice  '), true);
    });
  });
}
