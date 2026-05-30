import 'package:flutter/material.dart';
import 'constants/constants.dart';
import 'pages/pages.dart';
import 'services/favorites_service.dart';
import 'widgets/widgets.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,

      /// ─── Text Scaling Fix (safe + modern) ─────────────────
      builder: (ctx, child) {
        final mediaQuery = MediaQuery.of(ctx);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },

      /// ─── Theme ─────────────────────────────────────────────
      theme: ThemeData(
        scaffoldBackgroundColor: C.bg,
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'sans-serif',

        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),

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