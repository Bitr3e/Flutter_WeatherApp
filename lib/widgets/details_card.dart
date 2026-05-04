import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class DetailsCard extends StatelessWidget {
  final WeatherData data;
  const DetailsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
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
          Text("Today's Details",
              style: TextStyle(
                color: C.white,
                fontSize: R.font(context, 15),
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 16),
          _row(context, [
            _tile(context, Icons.thermostat_rounded,
                'Feels Like', '${data.feelsLike.round()}°C'),
            _tile(context, Icons.water_drop_rounded,
                'Humidity', '${data.humidity}%'),
          ]),
          const SizedBox(height: Dims.itemGap),
          _row(context, [
            _tile(context, Icons.compress_rounded,
                'Pressure', '${data.pressure} hPa'),
            _tile(context, Icons.visibility_rounded,
                'Visibility', '${(data.visibility / 1000).toStringAsFixed(1)} km'),
          ]),
          const SizedBox(height: Dims.itemGap),
          _row(context, [
            _tile(context, Icons.arrow_downward_rounded,
                'Min Temp', '${data.tempMin.round()}°C'),
            _tile(context, Icons.arrow_upward_rounded,
                'Max Temp', '${data.tempMax.round()}°C'),
          ]),
        ],
      ),
    );
  }

  Widget _row(BuildContext ctx, List<Widget> children) =>
      Row(children: children.map((w) => Expanded(child: w)).toList());

  Widget _tile(BuildContext ctx, IconData icon, String label, String val) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: C.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: C.accent, size: 17),
      ),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(color: C.grey, fontSize: R.font(ctx, 10))),
        Text(val,
            style: TextStyle(
              color: C.white,
              fontSize: R.font(ctx, 13),
              fontWeight: FontWeight.w600,
            )),
      ]),
    ]);
  }
}