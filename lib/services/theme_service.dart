import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService _instance = ThemeService._();
  static ThemeService get instance => _instance;

  final ValueNotifier<bool> isDark = ValueNotifier(true);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('isDark') ?? true;
    isDark.value = dark;
    C.isDark = dark;
  }

  Future<void> toggle() async {
    isDark.value = !isDark.value;
    C.isDark = isDark.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark.value);
  }
}
