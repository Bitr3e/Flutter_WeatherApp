import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/utils.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 8, height: 8,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: C.accent),
      ),
      const SizedBox(width: 8),
      Text(title,
          style: TextStyle(
            color: C.white,
            fontSize: R.font(context, 16),
            fontWeight: FontWeight.w600,
          )),
    ]);
  }
}