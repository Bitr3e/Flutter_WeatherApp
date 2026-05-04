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
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(
          textScaler: TextScaler.linear(
            MediaQuery.of(ctx).textScaler.scale(1.0).clamp(0.85, 1.1),
          ),
        ),
        child: child!,
      ),
      theme: ThemeData(
        scaffoldBackgroundColor: C.bg,
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'sans-serif',
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const _MainShell(),
    );
  }
}

// ─── Shell ────────────────────────────────────────────────────────────────────

class _MainShell extends StatefulWidget {
  const _MainShell();
  @override State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _idx = 0;

  static const _pages = <Widget>[
    WeatherHomePage(),
    SearchPage(),
    AlertsPage(),
    MapPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: BottomNav(
        selected: _idx,
        onTap: (i) => setState(() => _idx = i),
      ),
    );
  }
}