import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import 'country_pins.dart';
import 'globe_painter.dart';

class MapPinTapLayer extends StatelessWidget {
  final double rotation;
  final double globeSize;
  final ValueChanged<MapCountryPin> onTap;
  final MapCountryPin? selectedPin;

  const MapPinTapLayer({
    required this.rotation,
    required this.globeSize,
    required this.onTap,
    required this.selectedPin,
  });

  @override
  Widget build(BuildContext context) {
    final cx = globeSize / 2;
    final cy = globeSize / 2;
    final r  = globeSize / 2;

    return Stack(
      children: countryPins.map((pin) {
        final pos = MapGlobePainter.project(pin.lon, pin.lat, cx, cy, r, rotation);
        if (pos == null) return const SizedBox.shrink();

        const tapSize = 38.0;
        return Positioned(
          left: pos.x - tapSize / 2,
          top : pos.y - tapSize / 2,
          child: GestureDetector(
            onTap: () => onTap(pin),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: tapSize, height: tapSize,
              child: selectedPin?.name == pin.name
                  ? null
                  : Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: C.card.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: C.divider, width: 0.5),
                  ),
                  child: Text(pin.emoji, style: const TextStyle(fontSize: 10)),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
