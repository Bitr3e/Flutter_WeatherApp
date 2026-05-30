import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/favorites_service.dart';
import 'services/temperature_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TemperatureService.instance.load();
  await FavoritesService.instance.load();

  // Lock to portrait — suits the tall 20:9 Realme C35 screen
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar blends with app background
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF1A1A2E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const WeatherApp());
}