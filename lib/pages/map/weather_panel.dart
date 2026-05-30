import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../services/temperature_service.dart';
import '../../utils/utils.dart';
import 'country_pins.dart';

class MapWeatherPanel extends StatelessWidget {
  final MapCountryPin pin;
  final WeatherData? weather;
  final bool loading;
  final String? error;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  const MapWeatherPanel({
    required this.pin,
    required this.weather,
    required this.loading,
    required this.error,
    required this.onClose,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: C.accent.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(pin.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pin.name,
                        style: TextStyle(
                          color: C.white,
                          fontSize: R.font(context, 17),
                          fontWeight: FontWeight.bold,
                        )),
                    Text(pin.city,
                        style: TextStyle(
                            color: C.grey,
                            fontSize: R.font(context, 12))),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: C.muted.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.close_rounded, color: C.grey, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2.5),
              ),
            )
          else if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(children: [
                Text(error!,
                    style: TextStyle(
                        color: C.grey, fontSize: R.font(context, 13)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: C.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Retry',
                        style: TextStyle(
                            color: C.white, fontSize: R.font(context, 13))),
                  ),
                ),
              ]),
            )
          else if (weather != null)
              _MapWeatherContent(data: weather!),
        ],
      ),
    );
  }
}

class _MapWeatherContent extends StatelessWidget {
  final WeatherData data;
  const _MapWeatherContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final t = TemperatureService.instance;
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${t.convert(data.temperature).round()}',
                style: TextStyle(
                  color: C.white,
                  fontSize: R.font(context, 52),
                  fontWeight: FontWeight.w200,
                  height: 1,
                )),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(t.unit(),
                  style: TextStyle(
                    color: C.white,
                    fontSize: R.font(context, 20),
                    fontWeight: FontWeight.w300,
                  )),
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Image.network(
              data.iconUrl,
              width: 60, height: 60,
              errorBuilder: (_, __, ___) =>
              Icon(Icons.wb_sunny_rounded, color: C.orange, size: 50),
            ),
            Text(data.capDesc,
                style: TextStyle(
                    color: C.grey, fontSize: R.font(context, 12))),
          ]),
        ],
      ),
      const SizedBox(height: 14),
      Container(height: 1, color: C.divider),
      const SizedBox(height: 14),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(context, Icons.water_drop_outlined, '${data.humidity}%', 'Humidity'),
          _stat(context, Icons.air_rounded, '${(data.windSpeed * 3.6).round()} km/h', 'Wind'),
          _stat(context, Icons.thermostat_rounded, '${t.convert(data.feelsLike).round()}${t.unit()}', 'Feels Like'),
          _stat(context, Icons.visibility_rounded, '${(data.visibility / 1000).round()} km', 'Visibility'),
        ],
      ),
    ]);
  }

  Widget _stat(BuildContext ctx, IconData icon, String val, String label) {
    return Column(children: [
      Icon(icon, color: C.accent, size: 16),
      const SizedBox(height: 4),
      Text(val,
          style: TextStyle(
            color: C.white,
            fontSize: R.font(ctx, 13),
            fontWeight: FontWeight.w600,
          )),
      Text(label,
          style: TextStyle(
              color: C.grey, fontSize: R.font(ctx, 10))),
    ]);
  }
}
