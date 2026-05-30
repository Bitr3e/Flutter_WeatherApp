import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class TopBar extends StatelessWidget {
  final WeatherData? data;
  final VoidCallback  onCityTap;
  final VoidCallback  onMenuTap;
  final VoidCallback  onCalendarTap;

  const TopBar({
    super.key,
    required this.data,
    required this.onCityTap,
    required this.onMenuTap,
    required this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dims.pagePadding, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // ── Hamburger Menu Button ──────────────────────────
          GestureDetector(
            onTap: onMenuTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: Dims.touchTarget,
              height: Dims.touchTarget,
              child: Center(
                child: Icon(Icons.menu_rounded, color: C.white, size: 26),
              ),
            ),
          ),

          // ── City Name / Location ───────────────────────────
          if (data != null)
            GestureDetector(
              onTap: onCityTap,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.location_on_rounded,
                    color: C.accent, size: 15),
                const SizedBox(width: 4),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: data!.cityName,
                      style: TextStyle(
                        color: C.white,
                        fontSize: R.font(context, 15),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ', ${data!.country}',
                      style: TextStyle(
                        color: C.accent,
                        fontSize: R.font(context, 15),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 3),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: C.grey, size: 17),
              ]),
            )
          else
            const SizedBox(),

          // ── Calendar Button ───────────────────────────────
          GestureDetector(
            onTap: onCalendarTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: Dims.touchTarget,
              height: Dims.touchTarget,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.calendar_today_outlined,
                      color: C.white, size: 19),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}