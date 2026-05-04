class HourlyForecast {
  final String time, icon;
  final double temperature;

  const HourlyForecast({
    required this.time,
    required this.icon,
    required this.temperature,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}