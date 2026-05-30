import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/temperature_service.dart';
import '../services/weather_service.dart';
import '../utils/utils.dart';
import 'map/country_pins.dart';
import 'map/globe_view.dart';
import 'map/weather_panel.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _rotateCtrl;
  late Animation<double>   _rotateAnim;

  final _svc = WeatherService();

  // Currently selected country info
  MapCountryPin? _selected;
  WeatherData? _weather;
  bool         _loadingWeather = false;
  String?      _weatherError;

  // Auto-rotate toggle
  bool _autoRotate = true;

  @override
  void initState() {
    super.initState();
    TemperatureService.instance.isCelsius.addListener(_onUnitChanged);
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _rotateAnim = Tween<double>(begin: 0, end: 1).animate(_rotateCtrl);
  }

  @override
  void dispose() {
    TemperatureService.instance.isCelsius.removeListener(_onUnitChanged);
    _rotateCtrl.dispose();
    super.dispose();
  }

  void _onUnitChanged() { if (mounted) setState(() {}); }

  void _toggleRotate() {
    setState(() {
      _autoRotate = !_autoRotate;
      if (_autoRotate) {
        _rotateCtrl.repeat();
      } else {
        _rotateCtrl.stop();
      }
    });
  }

  Future<void> _onCountryTap(MapCountryPin pin) async {
    // Pause rotation while viewing a country
    _rotateCtrl.stop();
    setState(() {
      _selected       = pin;
      _weather        = null;
      _weatherError   = null;
      _loadingWeather = true;
    });

    try {
      final data = await _svc.fetch(pin.city);
      if (!mounted) return;
      setState(() {
        _weather        = data;
        _loadingWeather = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weatherError   = e.toString().replaceFirst('Exception: ', '');
        _loadingWeather = false;
      });
    }
  }

  void _closePanel() {
    setState(() {
      _selected     = null;
      _weather      = null;
      _weatherError = null;
    });
    if (_autoRotate) _rotateCtrl.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final width  = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(
        children: [

          // ── Full-screen globe section ──────────────────────
          Positioned.fill(
            child: Column(children: [
              SizedBox(height: top + 60), // leave room for header
              Expanded(
                child: MapGlobeView(
                  rotateAnim   : _rotateAnim,
                  onCountryTap : _onCountryTap,
                  selectedPin  : _selected,
                  width        : width,
                ),
              ),
              if (_selected == null) const SizedBox(height: 100),
            ]),
          ),

          // ── Header ────────────────────────────────────────
          Positioned(
            top: top, left: 0, right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dims.pagePadding, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weather Map',
                      style: TextStyle(
                        color: C.white,
                        fontSize: R.font(context, 24),
                        fontWeight: FontWeight.bold,
                      )),
                  // Rotate toggle button
                  GestureDetector(
                    onTap: _toggleRotate,
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: _autoRotate
                            ? C.accent.withValues(alpha: 0.2)
                            : C.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _autoRotate
                              ? C.accent.withValues(alpha: 0.5)
                              : C.divider,
                        ),
                      ),
                      child: Icon(
                        _autoRotate
                            ? Icons.rotate_right_rounded
                            : Icons.pause_rounded,
                        color: _autoRotate ? C.accent : C.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Country hint label ────────────────────────────
          if (_selected == null)
            Positioned(
              bottom: 110, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: C.card.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: C.divider),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.touch_app_rounded,
                        color: C.accent, size: 15),
                    const SizedBox(width: 6),
                    Text('Tap a country pin to see weather',
                        style: TextStyle(
                            color: C.grey,
                            fontSize: R.font(context, 12))),
                  ]),
                ),
              ),
            ),

          // ── Weather panel (slides up when country tapped) ─
          if (_selected != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: MapWeatherPanel(
                pin            : _selected!,
                weather        : _weather,
                loading        : _loadingWeather,
                error          : _weatherError,
                onClose        : _closePanel,
                onRetry        : () => _onCountryTap(_selected!),
              ),
            ),
        ],
      ),
    );
  }
}