import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_data.dart';

void main() {
  group('WeatherData.fromJson', () {
    final validJson = {
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

    test('parses valid JSON correctly', () {
      final w = WeatherData.fromJson(validJson);
      expect(w.cityName, 'London');
      expect(w.country, 'GB');
      expect(w.description, 'clear sky');
      expect(w.icon, '01d');
      expect(w.temperature, 15.5);
      expect(w.feelsLike, 14.0);
      expect(w.tempMin, 12.0);
      expect(w.tempMax, 18.0);
      expect(w.humidity, 72);
      expect(w.pressure, 1013);
      expect(w.visibility, 10000);
      expect(w.clouds, 20);
      expect(w.windSpeed, 5.2);
    });

    test('generates hourly forecast', () {
      final w = WeatherData.fromJson(validJson);
      expect(w.hourly.length, 6);
      expect(w.hourly.first.time, 'Now');
    });

    test('iconUrl returns correct URL', () {
      final w = WeatherData.fromJson(validJson);
      expect(w.iconUrl, 'https://openweathermap.org/img/wn/01d@2x.png');
    });

    test('capDesc capitalizes first letter', () {
      final w = WeatherData.fromJson(validJson);
      expect(w.capDesc, 'Clear sky');
    });

    test('handles empty description', () {
      final json = Map<String, dynamic>.from(validJson);
      json['weather'] = [{'description': '', 'icon': '01d'}];
      final w = WeatherData.fromJson(json);
      expect(w.capDesc, '');
    });

    test('handles null clouds', () {
      final json = Map<String, dynamic>.from(validJson);
      json['clouds'] = null;
      final w = WeatherData.fromJson(json);
      expect(w.clouds, 0);
    });

    test('handles missing optional fields gracefully', () {
      final json = Map<String, dynamic>.from(validJson);
      json['main'] = {'temp': 20.0};
      json['weather'] = [{'description': 'sunny', 'icon': '01d'}];
      final w = WeatherData.fromJson(json);
      expect(w.temperature, 20.0);
      expect(w.feelsLike, 0.0);
      expect(w.humidity, 0);
    });
  });

  group('WeatherData', () {
    test('iconUrl getter', () {
      final data = WeatherData(
        cityName: 'Test',
        country: 'XX',
        description: 'test',
        icon: '10n',
        temperature: 25,
        feelsLike: 23,
        tempMin: 20,
        tempMax: 30,
        windSpeed: 10,
        humidity: 50,
        visibility: 5000,
        pressure: 1000,
        clouds: 50,
        hourly: [],
      );
      expect(data.iconUrl, 'https://openweathermap.org/img/wn/10n@2x.png');
    });
  });
}
