import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/temperature_service.dart';
import '../utils/utils.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> forecast;
  const DailyForecastWidget({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final t = TemperatureService.instance;
    return Container(
      padding: const EdgeInsets.all(Dims.cardPadding),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(Dims.cardRadius),
        border: Border.all(color: C.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('5-Day Forecast',
              style: TextStyle(
                color: C.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 14),
          ...forecast.map((day) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: R.w(context, 42),
                  child: Text(day.day,
                      style: TextStyle(
                        color: C.grey,
                        fontSize: R.font(context, 13),
                        fontWeight: FontWeight.w500,
                      )),
                ),
                Image.network(day.iconUrl,
                    width: 28, height: 28,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.cloud, color: C.grey, size: 22)),
                const Spacer(),
                Text('${t.convert(day.tempHigh).round()}°',
                    style: TextStyle(
                      color: C.white,
                      fontSize: R.font(context, 13),
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(width: 8),
                Text('${t.convert(day.tempLow).round()}°',
                    style: TextStyle(
                      color: C.muted,
                      fontSize: R.font(context, 13),
                    )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
