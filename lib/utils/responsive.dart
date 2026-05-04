import 'package:flutter/material.dart';

class R {
  /// Scale a base size relative to a 392dp-wide reference screen (Realme C35).
  static double w(BuildContext ctx, double base) {
    final width = MediaQuery.of(ctx).size.width;
    return base * (width / 392);
  }

  /// Scaled font size, clamped so text is never too tiny or too large.
  static double font(BuildContext ctx, double base) {
    return w(ctx, base).clamp(base * 0.85, base * 1.2);
  }
}