import '../models/hourly_forecast.dart';

class ForecastGenerator {
  static List<HourlyForecast> generate(double baseTemp, String icon) {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final h       = now.add(Duration(hours: i));
      final rawHour = h.hour;
      final label   = i == 0
          ? 'Now'
          : '${rawHour == 0 ? 12 : rawHour > 12 ? rawHour - 12 : rawHour}'
          '${rawHour >= 12 ? 'pm' : 'am'}';
      return HourlyForecast(
        time       : label,
        temperature: baseTemp + (i.isEven ? -0.5 : 0.5) * i,
        icon       : icon,
      );
    });
  }
}