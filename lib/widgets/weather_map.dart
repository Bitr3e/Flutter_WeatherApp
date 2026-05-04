import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../services/map_service.dart';

class WeatherMap extends StatelessWidget {
  final String layer;

  const WeatherMap({
    super.key,
    this.layer = "precipitation_new",
  });

  // Default center (Lipa City)
  static const LatLng _center = LatLng(13.9411, 121.1620);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _center,
        zoom: 10,
      ),

      // ✅ Correct way to add weather overlay
      tileOverlays: {
        TileOverlay(
          tileOverlayId: const TileOverlayId("weather"),
          tileProvider: _WeatherTileProvider(layer),
        ),
      },

      // Optional: cleaner UI
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}

/// ─── Weather Tile Provider ─────────────────────────────

class _WeatherTileProvider implements TileProvider {
  final String layer;

  _WeatherTileProvider(this.layer);

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final url = MapService.getTileUrl(layer, x, y, zoom!);

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return Tile(
          256,
          256,
          response.bodyBytes,
        );
      }
    } catch (_) {
      // silently fail
    }

    // fallback empty tile
    return Tile(
      256,
      256,
      Uint8List(0),
    );
  }
}