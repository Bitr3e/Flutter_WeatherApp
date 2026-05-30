import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/hourly_forecast.dart';
import 'package:weather_app/widgets/hourly_list.dart';

void main() {
  group('HourlyList', () {
    testWidgets('renders all hourly items', (tester) async {
      final hourly = List.generate(
        6,
        (i) => HourlyForecast(
          time: i == 0 ? 'Now' : '${i}pm',
          icon: '01d',
          temperature: 20.0 + i,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HourlyList(hourly: hourly),
          ),
        ),
      );

      expect(find.text('Now'), findsOneWidget);
      expect(find.text('1pm'), findsOneWidget);
      expect(find.text('2pm'), findsOneWidget);
    });
  });
}
