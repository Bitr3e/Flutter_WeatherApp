import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/hourly_forecast.dart';

void main() {
  group('HourlyForecast', () {
    test('creates with required fields', () {
      final h = HourlyForecast(time: '2pm', icon: '01d', temperature: 22.5);
      expect(h.time, '2pm');
      expect(h.icon, '01d');
      expect(h.temperature, 22.5);
    });

    test('iconUrl getter', () {
      final h = HourlyForecast(time: 'Now', icon: '10n', temperature: 18.0);
      expect(h.iconUrl, 'https://openweathermap.org/img/wn/10n@2x.png');
    });
  });
}
