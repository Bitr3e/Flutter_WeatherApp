import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  FavoritesService._();
  static final FavoritesService _instance = FavoritesService._();
  static FavoritesService get instance => _instance;

  final ValueNotifier<List<String>> cities = ValueNotifier([]);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favoriteCities') ?? [];
    cities.value = list;
  }

  Future<void> add(String city) async {
    if (cities.value.contains(city)) return;
    final updated = [...cities.value, city];
    cities.value = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteCities', updated);
  }

  Future<void> remove(String city) async {
    final updated = cities.value.where((c) => c != city).toList();
    cities.value = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteCities', updated);
  }

  bool contains(String city) => cities.value.contains(city);
}
