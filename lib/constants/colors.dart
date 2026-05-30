import 'package:flutter/material.dart';

class C {
  static bool isDark = true;

  static Color get bg      => isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF4F4F9);
  static Color get card    => isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFFFF);
  static Color get card2   => isDark ? const Color(0xFF16213E) : const Color(0xFFF0F0F5);
  static Color get accent  => const Color(0xFF4F8EF7);
  static Color get orange  => const Color(0xFFFF9500);
  static Color get white   => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A2E);
  static Color get grey    => isDark ? const Color(0xFF8B8FA8) : const Color(0xFF6B7280);
  static Color get muted   => isDark ? const Color(0xFF555870) : const Color(0xFF9CA3AF);
  static Color get divider => isDark ? const Color(0xFF252540) : const Color(0xFFE5E7EB);
  static Color get black   => const Color(0xFF000000);
}