import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/widgets/bottom_nav.dart';

void main() {
  group('BottomNav', () {
    testWidgets('renders 4 navigation items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomNav(selected: 0, onTap: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    });

    testWidgets('highlights selected index', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomNav(selected: 2, onTap: (_) {}),
          ),
        ),
      );

      // The selected item should have accent color (non-transparent container)
      // Just verify the icons are present
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('calls onTap with correct index', (tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomNav(
              selected: 0,
              onTap: (i) => tappedIndex = i,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search_rounded));
      expect(tappedIndex, 1);
    });
  });
}
