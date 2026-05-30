class Config {
  static const weatherApiKey  = String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');
  static const weatherBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const forecastBaseUrl = 'https://api.openweathermap.org/data/2.5/forecast';
  static const defaultCity    = 'Manila';
  static const requestTimeout = Duration(seconds: 10);
}
