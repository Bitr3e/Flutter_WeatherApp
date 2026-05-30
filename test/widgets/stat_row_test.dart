import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_data.dart';
import 'package:weather_app/widgets/stat_row.dart';

void main() {
  group('StatRow', () {
    testWidgets('renders humidity, wind and visibility', (tester) async {
      final data = WeatherData(
        cityName: 'Test',
        country: 'XX',
        description: 'test',
        icon: '01d',
        temperature: 25,
        feelsLike: 23,
        tempMin: 20,
        tempMax: 30,
        windSpeed: 5.0,
        humidity: 65,
        visibility: 8000,
        pressure: 1013,
        clouds: 30,
        hourly: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatRow(data: data),
          ),
        ),
      );

      expect(find.text('18 km/h'), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
      expect(find.text('8 km'), findsOneWidget);
    });
  });
}
