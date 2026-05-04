class MapService {
  static const String openWeatherApiKey = "";

  static String getTileUrl(String layer, int x, int y, int zoom) {
    return "https://tile.openweathermap.org/map/$layer/$zoom/$x/$y.png?appid=$openWeatherApiKey";
  }
}