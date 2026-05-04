import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/utils.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: C.bg,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            Dims.pagePadding, top + 14, Dims.pagePadding, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weather Map',
                style: TextStyle(
                  color: C.white,
                  fontSize: R.font(context, 26),
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: C.divider),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(children: [
                    RepaintBoundary(
                      child: CustomPaint(
                          painter: _GridPainter(), child: Container()),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_rounded,
                              color: C.accent.withOpacity(0.35), size: 60),
                          const SizedBox(height: 10),
                          Text('Interactive map coming soon',
                              style: TextStyle(
                                  color: C.grey,
                                  fontSize: R.font(context, 14))),
                          const SizedBox(height: 6),
                          Text(
                            'Integrate Google Maps for\nlive radar & weather layers',
                            style: TextStyle(
                                color: C.muted,
                                fontSize: R.font(context, 12)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grid Painter ─────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final line = Paint()..color = C.divider..strokeWidth = 1;
    for (double y = 0; y < s.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), line);
    }
    for (double x = 0; x < s.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.height), line);
    }
    final blob = Paint()..color = C.accent.withOpacity(0.06);
    canvas.drawCircle(Offset(s.width * .3, s.height * .4), 90, blob);
    canvas.drawCircle(Offset(s.width * .7, s.height * .6), 70, blob);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}