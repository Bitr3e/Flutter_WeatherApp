import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/hourly_forecast.dart';
import 'package:weather_app/utils/forecast_generator.dart';

void main() {
  group('ForecastGenerator.generate', () {
    test('returns 6 items', () {
      final result = ForecastGenerator.generate(25.0, '01d');
      expect(result.length, 6);
    });

    test('starts with "Now"', () {
      final result = ForecastGenerator.generate(25.0, '01d');
      expect(result.first.time, 'Now');
    });

    test('all items are HourlyForecast', () {
      final result = ForecastGenerator.generate(25.0, '01d');
      for (final item in result) {
        expect(item, isA<HourlyForecast>());
      }
    });

    test('uses provided icon', () {
      final result = ForecastGenerator.generate(25.0, '13d');
      for (final item in result) {
        expect(item.icon, '13d');
      }
    });
  });
}
