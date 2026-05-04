import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/config.dart';
import '../models/models.dart';

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
}