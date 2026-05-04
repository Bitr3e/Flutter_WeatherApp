class MapService {
  static const String openWeatherApiKey = "ac4a2adc2d23bbee1635725559ad7ced";

  static String getTileUrl(String layer, int x, int y, int zoom) {
    return "https://tile.openweathermap.org/map/$layer/$zoom/$x/$y.png?appid=$openWeatherApiKey";
  }
}