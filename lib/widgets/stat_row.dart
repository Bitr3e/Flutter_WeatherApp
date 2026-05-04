import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class StatRow extends StatelessWidget {
  final WeatherData data;
  const StatRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _chip(context, Icons.air_rounded,
              '${(data.windSpeed * 3.6).round()} km/h'),
          Container(width: 1, height: 20, color: C.divider),
          _chip(context, Icons.water_drop_outlined, '${data.humidity}%'),
          Container(width: 1, height: 20, color: C.divider),
          _chip(context, Icons.wb_sunny_outlined,
              '${(data.visibility / 1000).round()} km'),
        ],
      ),
    );
  }

  Widget _chip(BuildContext ctx, IconData icon, String val) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: C.grey, size: 15),
      const SizedBox(width: 5),
      Text(val,
          style: TextStyle(color: C.grey, fontSize: R.font(ctx, 12))),
    ]);
  }
}