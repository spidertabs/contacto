import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:contacto/shared/widgets/contact_avatar.dart';
import 'package:contacto/shared/widgets/empty_state.dart';

void main() {
  group('ContactAvatar widget', () {
    testWidgets('displays two-letter initials for full name',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ContactAvatar(name: 'Mary Wanjiku'))),
      );
      expect(find.text('MW'), findsOneWidget);
    });

    testWidgets('displays single initial for single name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ContactAvatar(name: 'Moses'))),
      );
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('displays ? for empty name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ContactAvatar(name: ''))),
      );
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('renders as a CircleAvatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ContactAvatar(name: 'Alice'))),
      );
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('custom radius is applied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
            home: Scaffold(body: ContactAvatar(name: 'Bob', radius: 32))),
      );
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 32);
    });

    testWidgets('initials are uppercase', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ContactAvatar(name: 'alice bob'))),
      );
      expect(find.text('AB'), findsOneWidget);
    });
  });

  group('EmptyState widget', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.people_outline,
              title: 'No contacts yet',
            ),
          ),
        ),
      );
      expect(find.text('No contacts yet'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.people_outline,
              title: 'No contacts yet',
              subtitle: 'Tap + to add one.',
            ),
          ),
        ),
      );
      expect(find.text('Tap + to add one.'), findsOneWidget);
    });

    testWidgets('does not render subtitle when omitted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.people_outline,
              title: 'Nothing here',
            ),
          ),
        ),
      );
      // Only the title should appear
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders the provided icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.search_off,
              title: 'No results',
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });
}
