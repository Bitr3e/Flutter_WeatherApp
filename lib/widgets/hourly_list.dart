import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class HourlyList extends StatelessWidget {
  final List<HourlyForecast> hourly;
  const HourlyList({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    final cardW = R.w(context, 70.0);
    final cardH = R.w(context, 112.0);

    return SizedBox(
      height: cardH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        addAutomaticKeepAlives: false,   // Saves memory on 4GB RAM device
        itemCount: hourly.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final h   = hourly[i];
          final now = i == 0;
          return RepaintBoundary(
            child: Container(
              width: cardW, height: cardH,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: now ? C.accent.withValues(alpha: 0.18) : C.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: now ? C.accent.withValues(alpha: 0.5) : C.divider,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.network(
                    h.iconUrl,
                    width: cardW * 0.55, height: cardW * 0.55,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.cloud, color: C.grey, size: cardW * 0.5),
                  ),
                  Text(h.time,
                      style: TextStyle(
                        color: now ? C.accent : C.grey,
                        fontSize: R.font(context, 11),
                      )),
                  Text('${h.temperature.round()}°',
                      style: TextStyle(
                        color: C.white,
                        fontSize: R.font(context, 15),
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}