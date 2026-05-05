import 'package:flutter/material.dart';
import 'constants/constants.dart';
import 'pages/pages.dart';
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

  // ← Remove "const" here — const can cause stale widget issues
  final List<Widget> _pages = [
    const WeatherHomePage(),
    const SearchPage(),
    const AlertsPage(),
    const MapPage(),       // ← make sure this is the NEW MapPage
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      // ← Add a safety clamp so index never goes out of range
      body: IndexedStack(
        index: _idx.clamp(0, _pages.length - 1),
        children: _pages,
      ),
      bottomNavigationBar: BottomNav(
        selected: _idx,
        onTap: (i) {
          if (i >= 0 && i < _pages.length) {
            setState(() => _idx = i);
          }
        },
      ),
    );
  }
}