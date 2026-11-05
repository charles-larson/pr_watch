import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService extends ValueNotifier<ThemeMode> {
  static final ThemeService instance = ThemeService._internal();
  static const _storageKey = 'THEME_MODE';
  final _storage = const FlutterSecureStorage();

  ThemeService._internal() : super(ThemeMode.dark);

  Future<void> load() async {
    try {
      final saved = await _storage.read(key: _storageKey);
      value = saved == ThemeMode.light.name ? ThemeMode.light : ThemeMode.dark;
    } catch (_) {
      value = ThemeMode.dark;
    }
  }

  Future<void> toggle() async {
    value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await save();
  }

  Future<void> save() => _storage.write(key: _storageKey, value: value.name);
}
