import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/utils.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: C.bg,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            Dims.pagePadding, top + 14, Dims.pagePadding, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weather Alerts',
                style: TextStyle(
                  color: C.white,
                  fontSize: R.font(context, 26),
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 22),
            const _AlertCard(
              icon : Icons.thunderstorm_rounded,
              title: 'Thunderstorm Warning',
              desc : 'Heavy thunderstorms expected between 3 PM – 8 PM today.',
              color: Colors.orange,
            ),
            const SizedBox(height: Dims.itemGap),
            const _AlertCard(
              icon : Icons.water_rounded,
              title: 'Flood Watch',
              desc : 'Low-lying areas may experience flooding due to heavy rain.',
              color: Colors.blue,
            ),
            const SizedBox(height: Dims.itemGap),
            const _AlertCard(
              icon : Icons.air_rounded,
              title: 'Strong Wind Advisory',
              desc : 'Winds up to 60 km/h expected throughout the evening.',
              color: C.accent,
            ),
            const SizedBox(height: 30),
            Center(
              child: Text('Alerts based on your current location.',
                  style: TextStyle(
                      color: C.muted, fontSize: R.font(context, 12))),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Alert Card ──────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String   title, desc;
  final Color    color;
  const _AlertCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    color: color,
                    fontSize: R.font(context, 14),
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 4),
              Text(desc,
                  style: TextStyle(
                      color: C.grey, fontSize: R.font(context, 12))),
            ],
          ),
        ),
      ]),
    );
  }
}