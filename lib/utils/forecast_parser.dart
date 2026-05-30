import '../models/daily_forecast.dart';

class ForecastParser {
  static List<DailyForecast> parse5Day(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>;
    if (list.isEmpty) return [];

    final Map<int, _DayAccum> dayMap = {};

    for (final item in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        (item['dt'] as int) * 1000,
      );
      final dayKey = DateTime(dt.year, dt.month, dt.day).millisecondsSinceEpoch;
      final temp = (item['main']['temp'] as num).toDouble();
      final icon = item['weather'][0]['icon'] as String;

      dayMap.putIfAbsent(dayKey, () => _DayAccum());
      final acc = dayMap[dayKey]!;
      acc.temps.add(temp);
      acc.icons.add(icon);
    }

    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    return dayMap.entries
      .where((e) => e.key > todayKey)
      .take(5)
      .map((e) {
        final acc = e.value;
        final midIcon = acc.icons[acc.icons.length ~/ 2];
        final dayName = _weekdayName(
          DateTime.fromMillisecondsSinceEpoch(e.key).weekday,
        );
        return DailyForecast(
          day: dayName,
          icon: midIcon,
          tempHigh: acc.temps.reduce((a, b) => a > b ? a : b),
          tempLow: acc.temps.reduce((a, b) => a < b ? a : b),
        );
      })
      .toList();
  }

  static String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }
}

class _DayAccum {
  final List<double> temps = [];
  final List<String> icons = [];
}
