import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemperatureService {
  TemperatureService._();
  static final TemperatureService _instance = TemperatureService._();
  static TemperatureService get instance => _instance;

  final ValueNotifier<bool> isCelsius = ValueNotifier(true);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isCelsius.value = prefs.getBool('isCelsius') ?? true;
  }

  Future<void> toggle() async {
    isCelsius.value = !isCelsius.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCelsius', isCelsius.value);
  }

  double convert(double celsius) =>
      isCelsius.value ? celsius : celsius * 9 / 5 + 32;

  String unit() => isCelsius.value ? '°C' : '°F';
}
