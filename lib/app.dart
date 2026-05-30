import 'package:flutter/material.dart';
import 'constants/constants.dart';
import 'pages/pages.dart';
import 'services/favorites_service.dart';
import 'services/theme_service.dart';
import 'widgets/widgets.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});
  @override State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  @override
  void initState() {
    super.initState();
    ThemeService.instance.isDark.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService.instance.isDark.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? C.bg : C.bg,
      useMaterial3: true,
      fontFamily: 'sans-serif',
      colorScheme: ColorScheme.fromSeed(
        seedColor: C.accent,
        brightness: brightness,
        surface: isDark ? C.card : C.card,
      ),
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,

      builder: (ctx, child) {
        final mediaQuery = MediaQuery.of(ctx);
        final scale = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: scale),
          child: child!,
        );
      },

      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeService.instance.isDark.value ? ThemeMode.dark : ThemeMode.light,

      home: const _MainShell(),
    );
  }
}

// ── Shell ────────────────────────────────────────────────────────────────────

class _MainShell extends StatefulWidget {
  const _MainShell();
  @override State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _idx = 0;
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _cities = _buildCities();
    FavoritesService.instance.cities.addListener(_onFavChanged);
  }

  @override
  void dispose() {
    FavoritesService.instance.cities.removeListener(_onFavChanged);
    super.dispose();
  }

  void _onFavChanged() {
    if (mounted) setState(() => _cities = _buildCities());
  }

  List<String> _buildCities() {
    final favs = FavoritesService.instance.cities.value;
    return favs.isEmpty ? ['Manila'] : favs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: IndexedStack(
        index: _idx.clamp(0, 3),
        children: [
          WeatherHomePage(cities: _cities),
          const SearchPage(),
          const AlertsPage(),
          const MapPage(),
        ],
      ),
      bottomNavigationBar: BottomNav(
        selected: _idx,
        onTap: (i) {
          if (i >= 0 && i < 4) {
            setState(() => _idx = i);
          }
        },
      ),
    );
  }
}