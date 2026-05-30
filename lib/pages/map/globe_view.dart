import 'package:flutter/material.dart';
import 'country_pins.dart';
import 'globe_painter.dart';
import 'pins_painter.dart';
import 'pin_tap_layer.dart';

class MapGlobeView extends StatefulWidget {
  final Animation<double> rotateAnim;
  final ValueChanged<MapCountryPin> onCountryTap;
  final MapCountryPin? selectedPin;
  final double width;

  const MapGlobeView({
    required this.rotateAnim,
    required this.onCountryTap,
    required this.selectedPin,
    required this.width,
  });

  @override
  State<MapGlobeView> createState() => _MapGlobeViewState();
}

class _MapGlobeViewState extends State<MapGlobeView> {
  double _dragOffset = 0.0;
  bool   _isDragging = false;

  void _onDragUpdate(DragUpdateDetails d, double globeSize) {
    setState(() {
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
              AnimatedBuilder(
                animation: widget.rotateAnim,
                builder: (_, __) => CustomPaint(
                  size: Size(globeSize, globeSize),
                  painter: MapGlobePainter(rotation: _totalRotation),
                ),
              ),
              AnimatedBuilder(
                animation: widget.rotateAnim,
                builder: (_, __) => CustomPaint(
                  size: Size(globeSize, globeSize),
                  painter: MapPinsPainter(
                    rotation: _totalRotation,
                    selectedPin: widget.selectedPin,
                  ),
                  child: SizedBox(
                    width: globeSize,
                    height: globeSize,
                    child: MapPinTapLayer(
                      rotation: _totalRotation,
                      globeSize: globeSize,
                      onTap: widget.onCountryTap,
                      selectedPin: widget.selectedPin,
                    ),
                  ),
                ),
              ),
              if (!_isDragging)
                Positioned(
                  bottom: globeSize * 0.07,
                  child: const AnimatedOpacity(
                    opacity: 0.45,
                    duration: Duration(milliseconds: 300),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.swipe_rounded, color: Colors.white, size: 14),
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
