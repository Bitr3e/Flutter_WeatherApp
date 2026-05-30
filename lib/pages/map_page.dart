import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/temperature_service.dart';
import '../services/weather_service.dart';
import '../utils/utils.dart';

// ─── MAP PAGE ────────────────────────────────────────────────────────────────

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
  _CountryPin? _selected;
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

  Future<void> _onCountryTap(_CountryPin pin) async {
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
                child: _GlobeView(
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
              child: _WeatherPanel(
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

// ─── GLOBE VIEW ──────────────────────────────────────────────────────────────

class _GlobeView extends StatefulWidget {
  final Animation<double> rotateAnim;
  final ValueChanged<_CountryPin> onCountryTap;
  final _CountryPin? selectedPin;
  final double width;

  const _GlobeView({
    required this.rotateAnim,
    required this.onCountryTap,
    required this.selectedPin,
    required this.width,
  });

  @override
  State<_GlobeView> createState() => _GlobeViewState();
}

class _GlobeViewState extends State<_GlobeView> {
  // Manual drag offset in turns (0.0–1.0 per full rotation)
  double _dragOffset = 0.0;
  bool   _isDragging = false;

  void _onDragUpdate(DragUpdateDetails d, double globeSize) {
    setState(() {
      // One full globe width = one full rotation
      _dragOffset += d.delta.dx / globeSize;
    });
  }

  void _onDragStart(DragStartDetails _) {
    setState(() => _isDragging = true);
  }

  void _onDragEnd(DragEndDetails _) {
    setState(() => _isDragging = false);
  }

  double get _totalRotation => widget.rotateAnim.value + _dragOffset;

  @override
  Widget build(BuildContext context) {
    final globeSize = widget.width * 0.88;

    return Center(
      child: SizedBox(
        width: globeSize,
        height: globeSize,
        child: GestureDetector(
          onHorizontalDragStart : _onDragStart,
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, globeSize),
          onHorizontalDragEnd   : _onDragEnd,
          child: Stack(
            alignment: Alignment.center,
            children: [

              // ── Outer glow ring ───────────────────────────
              Container(
                width: globeSize,
                height: globeSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x2200BFFF),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),

              // ── Animated rotating world map ───────────────
              AnimatedBuilder(
                animation: widget.rotateAnim,
                builder: (_, __) => CustomPaint(
                  size: Size(globeSize, globeSize),
                  painter: _GlobePainter(
                    rotation: _totalRotation,
                  ),
                ),
              ),

              // ── Country pins (on top of globe) ────────────
              AnimatedBuilder(
                animation: widget.rotateAnim,
                builder: (_, __) => CustomPaint(
                  size: Size(globeSize, globeSize),
                  painter: _PinsPainter(
                    rotation    : _totalRotation,
                    selectedPin : widget.selectedPin,
                  ),
                  child: SizedBox(
                    width: globeSize,
                    height: globeSize,
                    child: _PinTapLayer(
                      rotation    : _totalRotation,
                      globeSize   : globeSize,
                      onTap       : widget.onCountryTap,
                      selectedPin : widget.selectedPin,
                    ),
                  ),
                ),
              ),

              // ── Drag hint icon ────────────────────────────
              if (!_isDragging)
                Positioned(
                  bottom: globeSize * 0.07,
                  child: const AnimatedOpacity(
                    opacity: 0.45,
                    duration: Duration(milliseconds: 300),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.swipe_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('drag to spin',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w300)),
                    ]),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}

// ─── GLOBE PAINTER ───────────────────────────────────────────────────────────

class _GlobePainter extends CustomPainter {
  final double rotation; // 0.0 → 1.0

  const _GlobePainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2;

    // ── Ocean base — realistic Earth deep blue ─────────
    final oceanPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.3),
        colors: [
          Color(0xFF1A6B9A),
          Color(0xFF0D4D78),
          Color(0xFF072A4A),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, oceanPaint);

    // ── Clip everything inside the globe circle ────────
    canvas.save();
    canvas.clipPath(Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    // ── Subtle grid lines ──────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0x0CFFFFFF)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    for (int lat = -75; lat <= 75; lat += 15) {
      final y    = cy + (lat / 90) * r;
      final arcR = _arcRadius(r, lat.toDouble());
      if (arcR > 2) {
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx, y), width: arcR * 2, height: arcR * 0.28),
          gridPaint,
        );
      }
    }
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12 + rotation) * 2 * 3.14159;
      final x     = cx + r * 0.98 * _cosApprox(angle.toDouble());
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: (x - cx).abs() * 2,
          height: r * 1.96,
        ),
        gridPaint,
      );
    }

    // ── Continents ────────────────────────────────────
    _drawContinents(canvas, cx, cy, r, rotation);

    // ── Deep shadow on the night side ─────────────────
    final nightPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.7, 0.2),
        radius: 0.75,
        colors: [
          Colors.transparent,
          Color(0x55000A14),
          Color(0xBB000A14),
        ],
        stops: [0.35, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r, nightPaint);

    // ── Atmosphere rim — light blue halo ──────────────
    final rimPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Color(0x1280CFFF),
          Color(0x4A55AAFF),
          Color(0x6633AAFF),
        ],
        stops: [0.0, 0.72, 0.84, 0.93, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r, rimPaint);

    canvas.restore();

    // ── Specular sunlight glint ────────────────────────
    final highlightPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.45, -0.45),
        radius: 0.55,
        colors: [
          Color(0x22FFFFFF),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, highlightPaint);

    // ── Outer border ───────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = const Color(0x5577CCFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  double _arcRadius(double r, double lat) {
    final rad = lat * 3.14159 / 180;
    return r * _cosApprox(rad);
  }

  double _cosApprox(double x) => _sinApprox(x + 3.14159 / 2);

  double _sinApprox(double x) {
    // Simple Taylor approximation for sin
    x = x % (2 * 3.14159);
    if (x > 3.14159) x -= 2 * 3.14159;
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  void _drawContinents(Canvas canvas, double cx, double cy,
      double r, double rotation) {
    // ── Landmass layers ────────────────────────────────
    final landPaint   = Paint()..color = _landColor;
    final desertPaint = Paint()..color = _desertColor;
    final tundraPaint = Paint()..color = _tundraColor;
    final forestPaint = Paint()..color = _forestColor;
    final savannaPaint = Paint()..color = _savannaColor;
    final mountainPaint = Paint()..color = _mountainColor;
    final iceFillPaint = Paint()..color = _iceColor;
    final borderPaint = Paint()
      ..color = _borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // ── Draw base continent polygons ───────────────────
    _drawPolygon(canvas, _northAmerica, landPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _southAmerica, landPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _europe, landPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _africa, savannaPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _asia, landPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _australia, desertPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _greenland, tundraPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _antarctica, iceFillPaint, cx, cy, r, rotation);

    // ── Terrain sub-regions ────────────────────────────
    _drawPolygon(canvas, _saharaDesert, desertPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _amazonRainforest, forestPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _himalayas, mountainPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _scandinavianMtns, mountainPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _centralAsiaSteppe, tundraPaint, cx, cy, r, rotation);
    _drawPolygon(canvas, _arabianDesert, desertPaint, cx, cy, r, rotation);

    // ── Continent borders ──────────────────────────────
    _drawBorder(canvas, _northAmerica, borderPaint, cx, cy, r, rotation);
    _drawBorder(canvas, _southAmerica, borderPaint, cx, cy, r, rotation);
    _drawBorder(canvas, _europe, borderPaint, cx, cy, r, rotation);
    _drawBorder(canvas, _africa, borderPaint, cx, cy, r, rotation);
    _drawBorder(canvas, _asia, borderPaint, cx, cy, r, rotation);
    _drawBorder(canvas, _australia, borderPaint, cx, cy, r, rotation);
    _drawBorder(canvas, _greenland, borderPaint, cx, cy, r, rotation);
    _drawBorder(canvas, _antarctica, borderPaint, cx, cy, r, rotation);

    // ── Polar ice caps ─────────────────────────────────
    final iceStrokePaint = Paint()
      ..color = const Color(0xAABBDDFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final npRect = Rect.fromCenter(
        center: Offset(cx, cy - r * 0.83), width: r * 0.38, height: r * 0.14);
    canvas.drawOval(npRect, iceFillPaint);
    canvas.drawOval(npRect, iceStrokePaint);
    final spRect = Rect.fromCenter(
        center: Offset(cx, cy + r * 0.87), width: r * 0.48, height: r * 0.12);
    canvas.drawOval(spRect, iceFillPaint);
    canvas.drawOval(spRect, iceStrokePaint);
  }

  void _drawPolygon(Canvas canvas, List<_Coord> points, Paint paint,
      double cx, double cy, double r, double rotation) {
    final projected = <Offset>[];
    for (final p in points) {
      final pos = _projectToGlobe(p.lon, p.lat, cx, cy, r, rotation);
      if (pos == null) {
        // Flush current segment at edge of visible hemisphere
        if (projected.length >= 3) {
          canvas.drawPath(
            Path()..addPolygon(projected, true), paint);
        }
        projected.clear();
        continue;
      }
      projected.add(Offset(pos.x, pos.y));
    }
    if (projected.length >= 3) {
      canvas.drawPath(
        Path()..addPolygon(projected, true), paint);
    }
  }

  void _drawBorder(Canvas canvas, List<_Coord> points, Paint paint,
      double cx, double cy, double r, double rotation) {
    final projected = <Offset>[];
    for (final p in points) {
      final pos = _projectToGlobe(p.lon, p.lat, cx, cy, r, rotation);
      if (pos == null) {
        if (projected.length >= 2) {
          canvas.drawPath(
            Path()..addPolygon(projected, false), paint);
        }
        projected.clear();
        continue;
      }
      projected.add(Offset(pos.x, pos.y));
    }
    if (projected.length >= 2) {
      canvas.drawPath(
        Path()..addPolygon(projected, false), paint);
    }
  }

  _ProjectedPoint? _projectToGlobe(
      double lon, double lat, double cx, double cy, double r, double rotation) {
    // Rotate longitude by current animation rotation
    final adjustedLon = lon + rotation * 360;
    final lonRad = adjustedLon * 3.14159 / 180;
    final latRad = lat         * 3.14159 / 180;

    final x3d = _cosApprox(latRad) * _cosApprox(lonRad);
    final y3d = _sinApprox(latRad);
    final z3d = _cosApprox(latRad) * _sinApprox(lonRad);

    // Only show if facing toward viewer (z3d > 0 means front hemisphere)
    if (z3d < -0.1) return null;

    final scale = (z3d + 1) / 2; // 0.5 at equator edge, 1.0 at center front

    return _ProjectedPoint(
      x: cx + x3d * r * 0.97,
      y: cy - y3d * r * 0.97,
      scale: scale.clamp(0.3, 1.0),
    );
  }

  @override
  bool shouldRepaint(_GlobePainter old) => old.rotation != rotation;
}

class _Coord {
  final double lon, lat;
  const _Coord(this.lon, this.lat);
}

class _ProjectedPoint {
  final double x, y, scale;
  const _ProjectedPoint({required this.x, required this.y, required this.scale});
}

// ─── CONTINENT DATA ───────────────────────────────────────────────────────────

const _landColor    = Color(0xFF3A7D44);
const _desertColor  = Color(0xFFC8A96E);
const _tundraColor  = Color(0xFF8B9D6E);
const _forestColor  = Color(0xFF2D6B30);
const _iceColor     = Color(0xDDEEF5FF);
const _borderColor  = Color(0x442D6035);
const _savannaColor = Color(0xFF8B9B5A);
const _mountainColor = Color(0xFF6B4423);

// ── Continent outlines (counter-clockwise, lon/lat) ────────────────────────

const _northAmerica = <_Coord>[
  _Coord(-168, 66), _Coord(-162, 68), _Coord(-152, 64), _Coord(-142, 62),
  _Coord(-135, 60), _Coord(-130, 56), _Coord(-125, 50), _Coord(-124, 44),
  _Coord(-122, 38), _Coord(-118, 34), _Coord(-114, 30), _Coord(-110, 28),
  _Coord(-106, 24), _Coord(-100, 20), _Coord(-92, 18), _Coord(-86, 22),
  _Coord(-83, 26), _Coord(-80, 28), _Coord(-81, 31), _Coord(-78, 34),
  _Coord(-76, 38), _Coord(-74, 42), _Coord(-70, 44), _Coord(-66, 48),
  _Coord(-60, 50), _Coord(-56, 50), _Coord(-58, 54), _Coord(-62, 58),
  _Coord(-66, 62), _Coord(-72, 66), _Coord(-80, 70), _Coord(-90, 72),
  _Coord(-100, 72), _Coord(-112, 70), _Coord(-125, 70), _Coord(-140, 68),
  _Coord(-152, 68), _Coord(-162, 68),
];

const _southAmerica = <_Coord>[
  _Coord(-80, 10), _Coord(-77, 8), _Coord(-76, 2), _Coord(-72, 0),
  _Coord(-62, 2), _Coord(-52, 0), _Coord(-38, -2), _Coord(-35, -6),
  _Coord(-36, -12), _Coord(-38, -18), _Coord(-42, -22), _Coord(-48, -28),
  _Coord(-52, -33), _Coord(-58, -36), _Coord(-64, -42), _Coord(-68, -48),
  _Coord(-72, -52), _Coord(-76, -52), _Coord(-74, -46), _Coord(-72, -38),
  _Coord(-72, -28), _Coord(-74, -18), _Coord(-76, -8), _Coord(-78, -2),
];

const _europe = <_Coord>[
  _Coord(-10, 36), _Coord(-8, 42), _Coord(-2, 44), _Coord(2, 48),
  _Coord(6, 52), _Coord(8, 56), _Coord(10, 58), _Coord(12, 60),
  _Coord(16, 62), _Coord(20, 64), _Coord(24, 66), _Coord(28, 68),
  _Coord(32, 70), _Coord(30, 66), _Coord(26, 62), _Coord(24, 58),
  _Coord(22, 54), _Coord(20, 50), _Coord(18, 46), _Coord(14, 44),
  _Coord(12, 42), _Coord(14, 40), _Coord(16, 38), _Coord(18, 36),
  _Coord(22, 38), _Coord(26, 40), _Coord(28, 42), _Coord(30, 46),
  _Coord(28, 48), _Coord(26, 52), _Coord(22, 48), _Coord(18, 46),
  _Coord(14, 44), _Coord(12, 42), _Coord(8, 40), _Coord(4, 38),
];

const _africa = <_Coord>[
  _Coord(-16, 35), _Coord(-12, 32), _Coord(-6, 30), _Coord(0, 32),
  _Coord(6, 34), _Coord(10, 32), _Coord(12, 30), _Coord(18, 28),
  _Coord(24, 26), _Coord(28, 22), _Coord(32, 18), _Coord(38, 14),
  _Coord(40, 10), _Coord(42, 4), _Coord(44, 0), _Coord(42, -4),
  _Coord(40, -8), _Coord(38, -12), _Coord(36, -18), _Coord(32, -24),
  _Coord(28, -28), _Coord(22, -32), _Coord(18, -34), _Coord(16, -32),
  _Coord(12, -28), _Coord(10, -22), _Coord(10, -16), _Coord(8, -10),
  _Coord(4, -4), _Coord(0, 0), _Coord(-4, 4), _Coord(-8, 8),
  _Coord(-12, 12), _Coord(-16, 16), _Coord(-18, 20), _Coord(-16, 24),
  _Coord(-16, 28), _Coord(-16, 32),
];

const _asia = <_Coord>[
  _Coord(30, 70), _Coord(40, 72), _Coord(50, 74), _Coord(60, 76),
  _Coord(70, 74), _Coord(80, 74), _Coord(90, 74), _Coord(100, 74),
  _Coord(110, 74), _Coord(120, 74), _Coord(130, 72), _Coord(140, 70),
  _Coord(150, 68), _Coord(156, 64), _Coord(160, 62), _Coord(158, 58),
  _Coord(154, 54), _Coord(148, 50), _Coord(142, 48), _Coord(136, 46),
  _Coord(130, 44), _Coord(126, 40), _Coord(122, 38), _Coord(118, 36),
  _Coord(112, 34), _Coord(108, 32), _Coord(104, 30), _Coord(100, 28),
  _Coord(96, 24), _Coord(100, 20), _Coord(104, 16), _Coord(106, 10),
  _Coord(104, 6), _Coord(102, 2), _Coord(100, -2), _Coord(104, -6),
  _Coord(106, -8), _Coord(110, -8), _Coord(112, -6), _Coord(114, -2),
  _Coord(116, 0), _Coord(118, 4), _Coord(120, 8), _Coord(120, 12),
  _Coord(118, 14), _Coord(116, 18), _Coord(114, 22), _Coord(110, 24),
  _Coord(106, 26), _Coord(102, 28), _Coord(98, 28), _Coord(92, 28),
  _Coord(88, 26), _Coord(84, 24), _Coord(80, 22), _Coord(76, 20),
  _Coord(72, 18), _Coord(68, 20), _Coord(64, 22), _Coord(60, 24),
  _Coord(56, 26), _Coord(52, 28), _Coord(48, 28), _Coord(44, 30),
  _Coord(40, 32), _Coord(36, 34), _Coord(32, 36), _Coord(30, 40),
  _Coord(28, 44), _Coord(28, 48), _Coord(30, 52), _Coord(30, 56),
  _Coord(32, 60), _Coord(30, 64), _Coord(30, 68),
];

const _australia = <_Coord>[
  _Coord(116, -14), _Coord(120, -12), _Coord(126, -12), _Coord(132, -12),
  _Coord(138, -12), _Coord(142, -14), _Coord(146, -16), _Coord(150, -20),
  _Coord(152, -24), _Coord(150, -28), _Coord(148, -32), _Coord(146, -36),
  _Coord(140, -38), _Coord(136, -36), _Coord(132, -34), _Coord(128, -32),
  _Coord(124, -34), _Coord(120, -34), _Coord(116, -34), _Coord(114, -32),
  _Coord(112, -24), _Coord(112, -18), _Coord(114, -16),
];

const _greenland = <_Coord>[
  _Coord(-52, 76), _Coord(-44, 78), _Coord(-32, 80), _Coord(-20, 80),
  _Coord(-18, 78), _Coord(-18, 74), _Coord(-22, 70), _Coord(-28, 68),
  _Coord(-36, 66), _Coord(-44, 64), _Coord(-52, 64), _Coord(-56, 66),
  _Coord(-58, 70), _Coord(-56, 74),
];

const _antarctica = <_Coord>[
  _Coord(-180, -70), _Coord(-120, -72), _Coord(-60, -72), _Coord(0, -72),
  _Coord(60, -72), _Coord(120, -72), _Coord(180, -70), _Coord(180, -80),
  _Coord(120, -82), _Coord(60, -82), _Coord(0, -82), _Coord(-60, -82),
  _Coord(-120, -82), _Coord(-180, -80),
];

// ── Terrain sub-regions ─────────────────────────────────────────────────────

const _saharaDesert = <_Coord>[
  _Coord(-16, 32), _Coord(-10, 34), _Coord(0, 35), _Coord(10, 34),
  _Coord(20, 32), _Coord(28, 28), _Coord(32, 24), _Coord(36, 18),
  _Coord(34, 14), _Coord(28, 12), _Coord(20, 14), _Coord(12, 16),
  _Coord(4, 16), _Coord(-4, 16), _Coord(-12, 18), _Coord(-16, 22),
];

const _amazonRainforest = <_Coord>[
  _Coord(-78, -2), _Coord(-72, 2), _Coord(-64, 2), _Coord(-56, 0),
  _Coord(-50, -2), _Coord(-46, -6), _Coord(-48, -10), _Coord(-52, -14),
  _Coord(-58, -14), _Coord(-64, -12), _Coord(-70, -8), _Coord(-74, -6),
];

const _himalayas = <_Coord>[
  _Coord(74, 34), _Coord(78, 36), _Coord(82, 34), _Coord(86, 32),
  _Coord(90, 32), _Coord(94, 30), _Coord(98, 30), _Coord(100, 28),
  _Coord(96, 26), _Coord(92, 26), _Coord(88, 28), _Coord(84, 28),
  _Coord(80, 30), _Coord(76, 32),
];

const _scandinavianMtns = <_Coord>[
  _Coord(6, 62), _Coord(8, 64), _Coord(12, 66), _Coord(16, 68),
  _Coord(20, 70), _Coord(24, 70), _Coord(22, 68), _Coord(18, 66),
  _Coord(14, 64), _Coord(10, 62),
];

const _centralAsiaSteppe = <_Coord>[
  _Coord(50, 52), _Coord(60, 54), _Coord(70, 54), _Coord(80, 54),
  _Coord(90, 52), _Coord(100, 50), _Coord(110, 48), _Coord(120, 46),
  _Coord(110, 44), _Coord(100, 44), _Coord(90, 44), _Coord(80, 46),
  _Coord(70, 48), _Coord(60, 50),
];

const _arabianDesert = <_Coord>[
  _Coord(36, 28), _Coord(40, 30), _Coord(44, 28), _Coord(48, 26),
  _Coord(52, 24), _Coord(56, 22), _Coord(54, 18), _Coord(50, 16),
  _Coord(46, 14), _Coord(42, 14), _Coord(40, 18), _Coord(38, 22),
];

// ─── PINS PAINTER ────────────────────────────────────────────────────────────

class _PinsPainter extends CustomPainter {
  final double rotation;
  final _CountryPin? selectedPin;

  const _PinsPainter({required this.rotation, this.selectedPin});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2;

    canvas.save();
    canvas.clipPath(Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    for (final pin in _countryPins) {
      final pos = _project(pin.lon, pin.lat, cx, cy, r);
      if (pos == null) continue;

      final isSel  = selectedPin?.name == pin.name;
      final pinR   = (5.0 * pos.scale).clamp(3.0, 7.0);
      final color  = isSel ? C.orange : C.accent;

      // Pulse ring for selected pin
      if (isSel) {
        canvas.drawCircle(
          Offset(pos.x, pos.y),
          pinR * 2.5,
          Paint()
            ..color = C.orange.withValues(alpha: 0.25)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(pos.x, pos.y),
          pinR * 1.8,
          Paint()
            ..color = C.orange.withValues(alpha: 0.4)
            ..style = PaintingStyle.fill,
        );
      }

      // Pin dot
      canvas.drawCircle(
        Offset(pos.x, pos.y),
        pinR,
        Paint()..color = color,
      );
      // Pin border
      canvas.drawCircle(
        Offset(pos.x, pos.y),
        pinR,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    canvas.restore();
  }

  _ProjectedPoint? _project(
      double lon, double lat, double cx, double cy, double r) {
    final adjustedLon = lon + rotation * 360;
    final lonRad = adjustedLon * 3.14159 / 180;
    final latRad = lat * 3.14159 / 180;
    final sinLon = _sin(lonRad), cosLon = _cos(lonRad);
    final sinLat = _sin(latRad), cosLat = _cos(latRad);
    final x3d = cosLat * cosLon;
    final y3d = sinLat;
    final z3d = cosLat * sinLon;
    if (z3d < 0.05) return null;
    final scale = ((z3d + 1) / 2).clamp(0.4, 1.0);
    return _ProjectedPoint(
      x: cx + x3d * r * 0.95,
      y: cy - y3d * r * 0.95,
      scale: scale,
    );
  }

  double _sin(double x) {
    x = x % (2 * 3.14159);
    if (x > 3.14159) x -= 2 * 3.14159;
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  double _cos(double x) => _sin(x + 3.14159 / 2);

  @override
  bool shouldRepaint(_PinsPainter old) =>
      old.rotation != rotation || old.selectedPin != selectedPin;
}

// ─── PIN TAP LAYER ───────────────────────────────────────────────────────────
// Invisible GestureDetectors positioned over each visible pin

class _PinTapLayer extends StatelessWidget {
  final double rotation;
  final double globeSize;
  final ValueChanged<_CountryPin> onTap;
  final _CountryPin? selectedPin;

  const _PinTapLayer({
    required this.rotation,
    required this.globeSize,
    required this.onTap,
    required this.selectedPin,
  });

  _ProjectedPoint? _project(double lon, double lat) {
    final cx = globeSize / 2;
    final cy = globeSize / 2;
    final r  = globeSize / 2;
    final adjustedLon = lon + rotation * 360;
    final lonRad = adjustedLon * 3.14159 / 180;
    final latRad = lat * 3.14159 / 180;
    final sinLon = _sin(lonRad), cosLon = _cos(lonRad);
    final sinLat = _sin(latRad), cosLat = _cos(latRad);
    final x3d = cosLat * cosLon;
    final y3d = sinLat;
    final z3d = cosLat * sinLon;
    if (z3d < 0.05) return null;
    final scale = ((z3d + 1) / 2).clamp(0.4, 1.0);
    return _ProjectedPoint(
      x: cx + x3d * r * 0.95,
      y: cy - y3d * r * 0.95,
      scale: scale,
    );
  }

  double _sin(double x) {
    x = x % (2 * 3.14159);
    if (x > 3.14159) x -= 2 * 3.14159;
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  double _cos(double x) => _sin(x + 3.14159 / 2);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _countryPins.map((pin) {
        final pos = _project(pin.lon, pin.lat);
        if (pos == null) return const SizedBox.shrink();

        const tapSize = 38.0; // 38dp minimum touch target
        return Positioned(
          left: pos.x - tapSize / 2,
          top : pos.y - tapSize / 2,
          child: GestureDetector(
            onTap: () => onTap(pin),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: tapSize, height: tapSize,
              child: selectedPin?.name == pin.name
                  ? null // no label for selected (shown in panel)
                  : Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: C.card.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: C.divider, width: 0.5),
                  ),
                  child: Text(
                    pin.emoji,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── WEATHER PANEL ───────────────────────────────────────────────────────────

class _WeatherPanel extends StatelessWidget {
  final _CountryPin  pin;
  final WeatherData? weather;
  final bool         loading;
  final String?      error;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  const _WeatherPanel({
    required this.pin,
    required this.weather,
    required this.loading,
    required this.error,
    required this.onClose,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: C.accent.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Panel header ───────────────────────────────
          Row(
            children: [
              Text(pin.emoji,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pin.name,
                        style: TextStyle(
                          color: C.white,
                          fontSize: R.font(context, 17),
                          fontWeight: FontWeight.bold,
                        )),
                    Text(pin.city,
                        style: TextStyle(
                            color: C.grey,
                            fontSize: R.font(context, 12))),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: C.muted.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: C.grey, size: 18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Weather content ────────────────────────────
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                    color: C.accent, strokeWidth: 2.5),
              ),
            )
          else if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(children: [
                Text(error!,
                    style: TextStyle(
                        color: C.grey,
                        fontSize: R.font(context, 13)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: C.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Retry',
                        style: TextStyle(
                            color: C.white,
                            fontSize: R.font(context, 13))),
                  ),
                ),
              ]),
            )
          else if (weather != null)
              _WeatherContent(data: weather!),
        ],
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherData data;
  const _WeatherContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final t = TemperatureService.instance;
    return Column(children: [

      // ── Main weather row ─────────────────────────────
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Temperature
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${t.convert(data.temperature).round()}',
                style: TextStyle(
                  color: C.white,
                  fontSize: R.font(context, 52),
                  fontWeight: FontWeight.w200,
                  height: 1,
                )),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(t.unit(),
                  style: TextStyle(
                    color: C.white,
                    fontSize: R.font(context, 20),
                    fontWeight: FontWeight.w300,
                  )),
            ),
          ]),

          // Icon + description
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Image.network(
              data.iconUrl,
              width: 60, height: 60,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.wb_sunny_rounded,
                  color: C.orange, size: 50),
            ),
            Text(data.capDesc,
                style: TextStyle(
                    color: C.grey,
                    fontSize: R.font(context, 12))),
          ]),
        ],
      ),

      const SizedBox(height: 14),
      Container(height: 1, color: C.divider),
      const SizedBox(height: 14),

      // ── Stats row ────────────────────────────────────
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(context, Icons.water_drop_outlined,
              '${data.humidity}%', 'Humidity'),
          _stat(context, Icons.air_rounded,
              '${(data.windSpeed * 3.6).round()} km/h', 'Wind'),
          _stat(context, Icons.thermostat_rounded,
              '${t.convert(data.feelsLike).round()}${t.unit()}', 'Feels Like'),
          _stat(context, Icons.visibility_rounded,
              '${(data.visibility / 1000).round()} km', 'Visibility'),
        ],
      ),
    ]);
  }

  Widget _stat(BuildContext ctx, IconData icon,
      String val, String label) {
    return Column(children: [
      Icon(icon, color: C.accent, size: 16),
      const SizedBox(height: 4),
      Text(val,
          style: TextStyle(
            color: C.white,
            fontSize: R.font(ctx, 13),
            fontWeight: FontWeight.w600,
          )),
      Text(label,
          style: TextStyle(
              color: C.grey, fontSize: R.font(ctx, 10))),
    ]);
  }
}

// ─── COUNTRY PINS DATA ────────────────────────────────────────────────────────

class _CountryPin {
  final String name;   // Display name
  final String city;   // City name sent to weather API
  final String emoji;  // Country flag emoji
  final double lon;    // Longitude  (-180 to 180)
  final double lat;    // Latitude   (-90 to 90)

  const _CountryPin({
    required this.name,
    required this.city,
    required this.emoji,
    required this.lon,
    required this.lat,
  });
}

const _countryPins = <_CountryPin>[
  // Asia & Pacific
  _CountryPin(name:'Philippines', city:'Manila',        emoji:'🇵🇭', lon: 121.0, lat: 14.6),
  _CountryPin(name:'Japan',       city:'Tokyo',         emoji:'🇯🇵', lon: 139.7, lat: 35.7),
  _CountryPin(name:'China',       city:'Beijing',       emoji:'🇨🇳', lon: 116.4, lat: 39.9),
  _CountryPin(name:'India',       city:'New Delhi',     emoji:'🇮🇳', lon: 77.2,  lat: 28.6),
  _CountryPin(name:'South Korea', city:'Seoul',         emoji:'🇰🇷', lon: 126.9, lat: 37.6),
  _CountryPin(name:'Thailand',    city:'Bangkok',       emoji:'🇹🇭', lon: 100.5, lat: 13.7),
  _CountryPin(name:'Indonesia',   city:'Jakarta',       emoji:'🇮🇩', lon: 106.8, lat: -6.2),
  _CountryPin(name:'Singapore',   city:'Singapore',     emoji:'🇸🇬', lon: 103.8, lat: 1.3),
  _CountryPin(name:'Australia',   city:'Sydney',        emoji:'🇦🇺', lon: 151.2, lat: -33.9),
  _CountryPin(name:'UAE',         city:'Dubai',         emoji:'🇦🇪', lon: 55.3,  lat: 25.2),
  _CountryPin(name:'Saudi Arabia',city:'Riyadh',        emoji:'🇸🇦', lon: 46.7,  lat: 24.7),

  // Europe
  _CountryPin(name:'UK',          city:'London',        emoji:'🇬🇧', lon: -0.1,  lat: 51.5),
  _CountryPin(name:'France',      city:'Paris',         emoji:'🇫🇷', lon: 2.3,   lat: 48.9),
  _CountryPin(name:'Germany',     city:'Berlin',        emoji:'🇩🇪', lon: 13.4,  lat: 52.5),
  _CountryPin(name:'Italy',       city:'Rome',          emoji:'🇮🇹', lon: 12.5,  lat: 41.9),
  _CountryPin(name:'Spain',       city:'Madrid',        emoji:'🇪🇸', lon: -3.7,  lat: 40.4),
  _CountryPin(name:'Russia',      city:'Moscow',        emoji:'🇷🇺', lon: 37.6,  lat: 55.8),

  // Americas
  _CountryPin(name:'USA',         city:'New York',      emoji:'🇺🇸', lon: -74.0, lat: 40.7),
  _CountryPin(name:'Canada',      city:'Toronto',       emoji:'🇨🇦', lon: -79.4, lat: 43.7),
  _CountryPin(name:'Brazil',      city:'Sao Paulo',     emoji:'🇧🇷', lon: -46.6, lat: -23.5),
  _CountryPin(name:'Mexico',      city:'Mexico City',   emoji:'🇲🇽', lon: -99.1, lat: 19.4),
  _CountryPin(name:'Argentina',   city:'Buenos Aires',  emoji:'🇦🇷', lon: -58.4, lat: -34.6),

  // Africa
  _CountryPin(name:'Egypt',       city:'Cairo',         emoji:'🇪🇬', lon: 31.2,  lat: 30.0),
  _CountryPin(name:'Nigeria',     city:'Lagos',         emoji:'🇳🇬', lon: 3.4,   lat: 6.5),
  _CountryPin(name:'South Africa',city:'Cape Town',     emoji:'🇿🇦', lon: 18.4,  lat: -33.9),
];