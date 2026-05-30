import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'constants/config.dart';
import 'services/favorites_service.dart';
import 'services/temperature_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TemperatureService.instance.load();
  await FavoritesService.instance.load();
  await ThemeService.instance.load();

  if (Config.weatherApiKey.isEmpty) {
    runApp(const _MissingApiKeyApp());
    return;
  }

  // Lock to portrait
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

class _MissingApiKeyApp extends StatelessWidget {
  const _MissingApiKeyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.key_off_rounded,
                    color: Color(0xFFFF9500), size: 64),
                const SizedBox(height: 24),
                const Text(
                  'API Key Missing',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pass your OpenWeatherMap API key via --dart-define:\n\n'
                  'flutter run --dart-define=WEATHER_API_KEY=your_key_here',
                  style: TextStyle(
                    color: Color(0xFF8B8FA8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
