import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../constants/constants.dart';

enum _WeatherType { clear, cloudy, rainy, snowy, misty }

_WeatherType _typeFromIcon(String icon) {
  if (icon.isEmpty) return _WeatherType.clear;
  final code = icon.substring(0, 2);
  switch (code) {
    case '01': return _WeatherType.clear;
    case '02':
    case '03':
    case '04': return _WeatherType.cloudy;
    case '09':
    case '10':
    case '11': return _WeatherType.rainy;
    case '13': return _WeatherType.snowy;
    case '50': return _WeatherType.misty;
    default:   return _WeatherType.clear;
  }
}

class _Particle {
  double x, y, speed, size, opacity, drift;
  _Particle(this.x, this.y, this.speed, this.size, this.opacity, this.drift);
}

class WeatherBackground extends StatefulWidget {
  final String iconCode;
  const WeatherBackground({super.key, required this.iconCode});

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _particles = <_Particle>[];
  final _rng = Random(42);
  _WeatherType _type = _WeatherType.clear;
  int _particleCount = 0;

  @override
  void initState() {
    super.initState();
    _initParticles();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(WeatherBackground old) {
    super.didUpdateWidget(old);
    if (old.iconCode != widget.iconCode) _initParticles();
  }

  @override
  void dispose() { _ticker.dispose(); super.dispose(); }

  void _initParticles() {
    _type = _typeFromIcon(widget.iconCode);
    _particles.clear();

    switch (_type) {
      case _WeatherType.clear:
      case _WeatherType.cloudy:
        _particleCount = 20;
        break;
      case _WeatherType.rainy:
        _particleCount = 60;
        break;
      case _WeatherType.snowy:
        _particleCount = 40;
        break;
      case _WeatherType.misty:
        _particleCount = 15;
        break;
    }

    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_Particle(
        _rng.nextDouble(), _rng.nextDouble(),
        0.005 + _rng.nextDouble() * 0.02,
        1.0 + _rng.nextDouble() * 3.0,
        0.15 + _rng.nextDouble() * 0.4,
        _rng.nextDouble() * 0.5 - 0.25,
      ));
    }
  }

  void _onTick(Duration elapsed) {
    const dt = 1.0 / 60;
    for (final p in _particles) {
      p.y += p.speed * dt * 60;
      p.x += p.drift * dt * 60;
      if (p.y > 1.1) { p.y = -0.1; p.x = _rng.nextDouble(); }
      if (p.x > 1.1) p.x = -0.1;
      if (p.x < -0.1) p.x = 1.1;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _BgPainter(_type, _particles),
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final _WeatherType type;
  final List<_Particle> particles;

  _BgPainter(this.type, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    switch (type) {
      case _WeatherType.clear:
        _drawSparkles(canvas, w, h, paint);
        break;
      case _WeatherType.cloudy:
        _drawClouds(canvas, w, h);
        break;
      case _WeatherType.rainy:
        _drawRain(canvas, w, h, paint);
        break;
      case _WeatherType.snowy:
        _drawSnow(canvas, w, h, paint);
        break;
      case _WeatherType.misty:
        _drawMist(canvas, w, h, paint);
        break;
    }
  }

  void _drawSparkles(Canvas canvas, double w, double h, Paint paint) {
    for (final p in particles) {
      paint.color = C.white.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(p.x * w, p.y * h), p.size * 0.5, paint);
    }
  }

  void _drawClouds(Canvas canvas, double w, double h) {
    final paint = Paint()..color = C.grey.withValues(alpha: 0.04);
    for (final p in particles) {
      canvas.drawCircle(
        Offset(p.x * w, p.y * h),
        p.size * (w / 60),
        paint..color = C.grey.withValues(alpha: p.opacity * 0.12),
      );
    }
  }

  void _drawRain(Canvas canvas, double w, double h, Paint paint) {
    paint.color = C.accent.withValues(alpha: 0.15);
    paint.strokeWidth = 1.2;
    paint.style = PaintingStyle.stroke;
    final len = w / 40;
    for (final p in particles) {
      canvas.drawLine(
        Offset(p.x * w, p.y * h),
        Offset(p.x * w - len * 0.3, p.y * h + len),
        paint,
      );
    }
  }

  void _drawSnow(Canvas canvas, double w, double h, Paint paint) {
    for (final p in particles) {
      paint.color = C.white.withValues(alpha: p.opacity * 0.6);
      canvas.drawCircle(Offset(p.x * w, p.y * h), p.size * 0.8, paint);
    }
  }

  void _drawMist(Canvas canvas, double w, double h, Paint paint) {
    for (final p in particles) {
      paint.color = C.grey.withValues(alpha: p.opacity * 0.08);
      canvas.drawCircle(Offset(p.x * w, p.y * h), p.size * (w / 40), paint);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) =>
      old.type != type || old.particles != particles;
}
