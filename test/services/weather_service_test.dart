import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weather_app/models/models.dart';
import 'package:weather_app/services/weather_service.dart';

const _validWeatherJson = {
  'name': 'London',
  'sys': {'country': 'GB'},
  'weather': [
    {'description': 'clear sky', 'icon': '01d'}
  ],
  'main': {
    'temp': 15.5,
    'feels_like': 14.0,
    'temp_min': 12.0,
    'temp_max': 18.0,
    'humidity': 72,
    'pressure': 1013,
  },
  'visibility': 10000,
  'wind': {'speed': 5.2},
  'clouds': {'all': 20},
};

// Far-future timestamps to avoid DateTime.now() filtering
final _futureNow = DateTime.now().add(const Duration(days: 30));
final _futureTimestamps = [
  _futureNow.millisecondsSinceEpoch ~/ 1000,
  _futureNow.add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000,
  _futureNow.add(const Duration(hours: 48)).millisecondsSinceEpoch ~/ 1000,
];

void main() {
  group('WeatherService.fetch', () {
    test('returns WeatherData on 200', () async {
      final mock = MockClient((req) async {
        return http.Response(jsonEncode(_validWeatherJson), 200);
      });
      final svc = WeatherService(client: mock);
      final result = await svc.fetch('London');
      expect(result, isA<WeatherData>());
      expect(result.cityName, 'London');
      expect(result.temperature, 15.5);
    });

    test('throws on 404', () async {
      final mock = MockClient((req) async {
        return http.Response('{"message":"city not found"}', 404);
      });
      final svc = WeatherService(client: mock);
      expect(() => svc.fetch('Atlantis'), throwsA(predicate(
        (e) => e.toString().contains('not found'))));
    });

    test('throws on 401', () async {
      final mock = MockClient((req) async {
        return http.Response('{"message":"invalid key"}', 401);
      });
      final svc = WeatherService(client: mock);
      expect(() => svc.fetch('London'), throwsA(predicate(
        (e) => e.toString().contains('Invalid API key'))));
    });

    test('throws on server error', () async {
      final mock = MockClient((req) async {
        return http.Response('', 500);
      });
      final svc = WeatherService(client: mock);
      expect(() => svc.fetch('London'), throwsA(predicate(
        (e) => e.toString().contains('Server error'))));
    });
  });

  group('WeatherService.fetchByCoords', () {
    test('returns WeatherData on 200', () async {
      final mock = MockClient((req) async {
        expect(req.url.toString(), contains('lat=51.5'));
        expect(req.url.toString(), contains('lon=-0.1'));
        return http.Response(jsonEncode(_validWeatherJson), 200);
      });
      final svc = WeatherService(client: mock);
      final result = await svc.fetchByCoords(51.5, -0.1);
      expect(result, isA<WeatherData>());
    });

    test('throws on 401', () async {
      final mock = MockClient((req) async {
        return http.Response('', 401);
      });
      final svc = WeatherService(client: mock);
      expect(() => svc.fetchByCoords(0, 0), throwsA(predicate(
        (e) => e.toString().contains('Invalid API key'))));
    });
  });

  group('WeatherService.fetchForecast', () {
    test('returns List<DailyForecast> on 200', () async {
      final mock = MockClient((req) async {
        final json = {
          'list': _futureTimestamps.map((dt) => {
            'dt': dt,
            'main': {'temp': 20.0, 'temp_min': 18.0, 'temp_max': 22.0},
            'weather': [{'icon': '01d'}],
          }).toList(),
        };
        return http.Response(jsonEncode(json), 200);
      });
      final svc = WeatherService(client: mock);
      final result = await svc.fetchForecast('London');
      expect(result, isA<List<DailyForecast>>());
      expect(result.length, greaterThan(0));
    });

    test('throws on 404', () async {
      final mock = MockClient((req) async {
        return http.Response('', 404);
      });
      final svc = WeatherService(client: mock);
      expect(() => svc.fetchForecast('Atlantis'), throwsA(predicate(
        (e) => e.toString().contains('not found'))));
    });
  });
}
