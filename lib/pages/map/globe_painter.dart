import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'continent_data.dart';

class MapProjectedPoint {
  final double x, y, scale;
  const MapProjectedPoint({required this.x, required this.y, required this.scale});
}

class MapGlobePainter extends CustomPainter {
  final double rotation;
  const MapGlobePainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2;

    final oceanPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.3),
        colors: [Color(0xFF1A6B9A), Color(0xFF0D4D78), Color(0xFF072A4A)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, oceanPaint);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    final gridPaint = Paint()
      ..color = const Color(0x0CFFFFFF)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    for (int lat = -75; lat <= 75; lat += 15) {
      final y    = cy + (lat / 90) * r;
      final arcR = _arcRadius(r, lat.toDouble());
      if (arcR > 2) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, y), width: arcR * 2, height: arcR * 0.28),
          gridPaint,
        );
      }
    }
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12 + rotation) * 2 * math.pi;
      final x     = cx + r * 0.98 * math.cos(angle);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy), width: (x - cx).abs() * 2, height: r * 1.96),
        gridPaint,
      );
    }

    _drawContinents(canvas, cx, cy, r, rotation);

    final nightPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.7, 0.2), radius: 0.75,
        colors: [Colors.transparent, Color(0x55000A14), Color(0xBB000A14)],
        stops: [0.35, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r, nightPaint);

    final rimPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.center, radius: 1.0,
        colors: [Colors.transparent, Colors.transparent, Color(0x1280CFFF), Color(0x4A55AAFF), Color(0x6633AAFF)],
        stops: [0.0, 0.72, 0.84, 0.93, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r, rimPaint);

    canvas.restore();

    final highlightPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.45, -0.45), radius: 0.55,
        colors: [Color(0x22FFFFFF), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, highlightPaint);

    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()..color = const Color(0x5577CCFF)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
  }

  double _arcRadius(double r, double lat) {
    return r * math.cos(lat * math.pi / 180);
  }

  void _drawContinents(Canvas canvas, double cx, double cy, double r, double rotation) {
    final continentPolygons = <List<MapCoord>>[
      northAmerica, southAmerica, europe, africa, asia,
      australia, greenland, antarctica,
    ];
    final continentColors = <Color>[
      landColor, landColor, landColor, savannaColor,
      landColor, desertColor, tundraColor, iceColor,
    ];
    final terrainPolygons = <List<MapCoord>>[
      saharaDesert, amazonRainforest, himalayas,
      scandinavianMtns, centralAsiaSteppe, arabianDesert,
    ];
    final terrainColors = <Color>[
      desertColor, forestColor, mountainColor,
      mountainColor, tundraColor, desertColor,
    ];

    for (int i = 0; i < continentPolygons.length; i++) {
      _drawPolygon(canvas, continentPolygons[i], continentColors[i], cx, cy, r, rotation);
      _drawBorder(canvas, continentPolygons[i], borderColor, cx, cy, r, rotation);
    }
    for (int i = 0; i < terrainPolygons.length; i++) {
      _drawPolygon(canvas, terrainPolygons[i], terrainColors[i], cx, cy, r, rotation);
    }

    final iceFillPaint = Paint()..color = iceColor;
    final iceStrokePaint = Paint()..color = const Color(0xAABBDDFF)..style = PaintingStyle.stroke..strokeWidth = 0.8;

    final npRect = Rect.fromCenter(
        center: Offset(cx, cy - r * 0.83), width: r * 0.38, height: r * 0.14);
    canvas.drawOval(npRect, iceFillPaint..style = PaintingStyle.fill);
    canvas.drawOval(npRect, iceStrokePaint);
    final spRect = Rect.fromCenter(
        center: Offset(cx, cy + r * 0.87), width: r * 0.48, height: r * 0.12);
    canvas.drawOval(spRect, iceFillPaint..style = PaintingStyle.fill);
    canvas.drawOval(spRect, iceStrokePaint);
  }

  void _drawPolygon(Canvas canvas, List<MapCoord> points, Color color,
      double cx, double cy, double r, double rotation) {
    final projected = <Offset>[];
    for (final p in points) {
      final pos = _projectToGlobe(p.lon, p.lat, cx, cy, r, rotation);
      if (pos == null) {
        if (projected.length >= 3) {
          canvas.drawPath(Path()..addPolygon(projected, true), Paint()..color = color);
        }
        projected.clear();
        continue;
      }
      projected.add(Offset(pos.x, pos.y));
    }
    if (projected.length >= 3) {
      canvas.drawPath(Path()..addPolygon(projected, true), Paint()..color = color);
    }
  }

  void _drawBorder(Canvas canvas, List<MapCoord> points, Color color,
      double cx, double cy, double r, double rotation) {
    final projected = <Offset>[];
    for (final p in points) {
      final pos = _projectToGlobe(p.lon, p.lat, cx, cy, r, rotation);
      if (pos == null) {
        if (projected.length >= 2) {
          canvas.drawPath(Path()..addPolygon(projected, false), Paint()
            ..color = color..style = PaintingStyle.stroke..strokeWidth = 0.5);
        }
        projected.clear();
        continue;
      }
      projected.add(Offset(pos.x, pos.y));
    }
    if (projected.length >= 2) {
      canvas.drawPath(Path()..addPolygon(projected, false), Paint()
        ..color = color..style = PaintingStyle.stroke..strokeWidth = 0.5);
    }
  }

  static MapProjectedPoint? _projectToGlobe(
      double lon, double lat, double cx, double cy, double r, double rotation) {
    final adjustedLon = lon + rotation * 360;
    final lonRad = adjustedLon * math.pi / 180;
    final latRad = lat * math.pi / 180;

    final x3d = math.cos(latRad) * math.cos(lonRad);
    final y3d = math.sin(latRad);
    final z3d = math.cos(latRad) * math.sin(lonRad);

    if (z3d < -0.1) return null;

    final scale = ((z3d + 1) / 2).clamp(0.3, 1.0);

    return MapProjectedPoint(
      x: cx + x3d * r * 0.97,
      y: cy - y3d * r * 0.97,
      scale: scale,
    );
  }

  static MapProjectedPoint? project(double lon, double lat,
      double cx, double cy, double r, double rotation) {
    return _projectToGlobe(lon, lat, cx, cy, r, rotation);
  }

  @override
  bool shouldRepaint(MapGlobePainter old) => old.rotation != rotation;
}
