class DailyForecast {
  final String day;
  final String icon;
  final double tempHigh;
  final double tempLow;

  const DailyForecast({
    required this.day,
    required this.icon,
    required this.tempHigh,
    required this.tempLow,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}
