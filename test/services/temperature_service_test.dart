import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/services/temperature_service.dart';

void main() {
  group('TemperatureService', () {
    test('defaults to Celsius', () {
      final svc = TemperatureService.instance;
      expect(svc.isCelsius.value, true);
      expect(svc.unit(), '°C');
    });

    test('convert returns Celsius when isCelsius is true', () {
      final svc = TemperatureService.instance;
      svc.isCelsius.value = true;
      expect(svc.convert(25.0), 25.0);
      expect(svc.convert(0.0), 0.0);
      expect(svc.convert(-10.0), -10.0);
    });

    test('convert returns Fahrenheit when isCelsius is false', () {
      final svc = TemperatureService.instance;
      svc.isCelsius.value = false;
      expect(svc.convert(0.0), 32.0);
      expect(svc.convert(25.0), 77.0);
      expect(svc.convert(100.0), 212.0);
    });

    test('toggle changes unit', () async {
      SharedPreferences.setMockInitialValues({});
      final svc = TemperatureService.instance;
      svc.isCelsius.value = true;
      await svc.toggle();
      expect(svc.isCelsius.value, false);
      expect(svc.unit(), '°F');
    });

    test('unit returns correct symbol', () {
      final svc = TemperatureService.instance;
      svc.isCelsius.value = true;
      expect(svc.unit(), '°C');
      svc.isCelsius.value = false;
      expect(svc.unit(), '°F');
    });
  });
}
