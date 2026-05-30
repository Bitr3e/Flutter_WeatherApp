import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/utils.dart';

class WeatherIcon extends StatelessWidget {
  final String iconUrl;
  const WeatherIcon({super.key, required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    final size = R.w(context, 150);
    return Center(
      child: SizedBox(
        width: size, height: size,
        child: Stack(alignment: Alignment.center, children: [
          // Radial glow — no blur, safe for Mali-G52 GPU
          Container(
            width: size, height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                C.orange.withValues(alpha: 0.22),
                C.orange.withValues(alpha: 0.05),
                Colors.transparent,
              ]),
            ),
          ),
          Image.network(
            iconUrl,
            width: size * 0.85, height: size * 0.85,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : SizedBox(
              width: size * 0.85, height: size * 0.85,
              child: const Center(
                child: CircularProgressIndicator(
                    color: C.orange, strokeWidth: 2),
              ),
            ),
            errorBuilder: (_, __, ___) =>
                Icon(Icons.wb_sunny_rounded, color: C.orange, size: size * 0.7),
          ),
        ]),
      ),
    );
  }
}