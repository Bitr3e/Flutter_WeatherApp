import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/widgets/error_view.dart';

void main() {
  group('ErrorView', () {
    testWidgets('renders message text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'City not found.',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('City not found.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('calls onRetry when button tapped', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Error!',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Try Again'));
      expect(retried, true);
    });
  });
}
