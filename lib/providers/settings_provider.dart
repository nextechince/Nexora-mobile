import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/settings_service.dart';

part 'settings_provider.g.dart';

@riverpod
class ThemeMode extends _$ThemeMode {
  @override
  ThemeMode build() {
    final settings = ref.watch(settingsServiceProvider);
    return settings.getThemeMode();
  }

  void toggle() {
    final current = state;
    state = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final service = ref.watch(settingsServiceProvider);
    service.setThemeMode(state);
  }
}