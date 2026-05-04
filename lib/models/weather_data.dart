import '../utils/cast_helpers.dart';
import '../utils/forecast_generator.dart';
import 'hourly_forecast.dart';

class WeatherData {
  final String cityName, country, description, icon;
  final double temperature, feelsLike, tempMin, tempMax, windSpeed;
  final int    humidity, visibility, pressure, clouds;
  final List<HourlyForecast> hourly;

  const WeatherData({
    required this.cityName,
    required this.country,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.windSpeed,
    required this.humidity,
    required this.visibility,
    required this.pressure,
    required this.clouds,
    required this.hourly,
  });

  factory WeatherData.fromJson(Map<String, dynamic> j) {
    final icon    = (j['weather'][0]['icon'] ?? '01d') as String;
    final temp    = asDouble(j['main']['temp']);

    return WeatherData(
      cityName   : (j['name']            ?? 'Unknown') as String,
      country    : (j['sys']['country']  ?? '')         as String,
      description: (j['weather'][0]['description'] ?? '') as String,
      icon       : icon,
      temperature: temp,
      feelsLike  : asDouble(j['main']['feels_like']),
      tempMin    : asDouble(j['main']['temp_min']),
      tempMax    : asDouble(j['main']['temp_max']),
      windSpeed  : asDouble(j['wind']['speed']),
      humidity   : asInt(j['main']['humidity']),
      visibility : asInt(j['visibility']),
      pressure   : asInt(j['main']['pressure']),
      clouds     : asInt(j['clouds']?['all']),
      hourly     : ForecastGenerator.generate(temp, icon),
    );
  }

  String get iconUrl  => 'https://openweathermap.org/img/wn/$icon@2x.png';
  String get capDesc  => description.isEmpty
      ? '' : '${description[0].toUpperCase()}${description.substring(1)}';
}