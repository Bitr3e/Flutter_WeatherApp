import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import 'country_pins.dart';
import 'globe_painter.dart';

class MapPinsPainter extends CustomPainter {
  final double rotation;
  final MapCountryPin? selectedPin;

  const MapPinsPainter({required this.rotation, this.selectedPin});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2;

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    for (final pin in countryPins) {
      final pos = MapGlobePainter.project(pin.lon, pin.lat, cx, cy, r, rotation);
      if (pos == null) continue;

      final isSel  = selectedPin?.name == pin.name;
      final pinR   = (5.0 * pos.scale).clamp(3.0, 7.0);
      final color  = isSel ? C.orange : C.accent;

      if (isSel) {
        canvas.drawCircle(Offset(pos.x, pos.y), pinR * 2.5,
          Paint()..color = C.orange.withValues(alpha: 0.25)..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(pos.x, pos.y), pinR * 1.8,
          Paint()..color = C.orange.withValues(alpha: 0.4)..style = PaintingStyle.fill);
      }

      canvas.drawCircle(Offset(pos.x, pos.y), pinR, Paint()..color = color);
      canvas.drawCircle(Offset(pos.x, pos.y), pinR,
        Paint()..color = Colors.white.withValues(alpha: 0.8)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(MapPinsPainter old) =>
      old.rotation != rotation || old.selectedPin != selectedPin;
}
