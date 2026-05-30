import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/config.dart';
import '../models/models.dart';
import '../utils/forecast_parser.dart';

class WeatherService {
  Future<WeatherData> fetch(String city) async {
    final uri = Uri.parse(
      '${Config.weatherBaseUrl}'
          '?q=${Uri.encodeComponent(city)}'
          '&appid=${Config.weatherApiKey}'
          '&units=metric',
    );

    final res = await http.get(uri).timeout(Config.requestTimeout);

    switch (res.statusCode) {
      case 200 : return WeatherData.fromJson(jsonDecode(res.body));
      case 404  : throw Exception('City "$city" not found.');
      case 401  : throw Exception('Invalid API key.');
      default   : throw Exception('Server error (${res.statusCode}).');
    }
  }

  Future<WeatherData> fetchByCoords(double lat, double lon) async {
    final uri = Uri.parse(
      '${Config.weatherBaseUrl}'
          '?lat=$lat&lon=$lon'
          '&appid=${Config.weatherApiKey}'
          '&units=metric',
    );

    final res = await http.get(uri).timeout(Config.requestTimeout);

    switch (res.statusCode) {
      case 200 : return WeatherData.fromJson(jsonDecode(res.body));
      case 401  : throw Exception('Invalid API key.');
      default   : throw Exception('Server error (${res.statusCode}).');
    }
  }

  Future<List<DailyForecast>> fetchForecast(String city) async {
    final uri = Uri.parse(
      '${Config.forecastBaseUrl}'
          '?q=${Uri.encodeComponent(city)}'
          '&appid=${Config.weatherApiKey}'
          '&units=metric',
    );

    final res = await http.get(uri).timeout(Config.requestTimeout);

    switch (res.statusCode) {
      case 200 : return ForecastParser.parse5Day(jsonDecode(res.body));
      case 404  : throw Exception('City "$city" not found.');
      case 401  : throw Exception('Invalid API key.');
      default   : throw Exception('Server error (${res.statusCode}).');
    }
  }
}