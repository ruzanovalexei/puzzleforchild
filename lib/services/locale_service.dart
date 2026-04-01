import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _localeKey = 'appLocale';
  static const String _isFirstLaunchKey = 'isFirstLaunch';
  
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  // Глобальный callback для уведомления об изменении локали
  static void Function(Locale)? onLocaleChanged;

  static const List<Locale> supportedLocales = [
    Locale('ru'),
    Locale('en'),
    Locale('zh'),
    Locale('ja'),
    Locale('tr'),
  ];

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirst = prefs.getBool(_isFirstLaunchKey) ?? true;
    return isFirst;
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, false);
  }

  Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? localeCode = prefs.getString(_localeKey);
    
    if (localeCode == null || localeCode.isEmpty) {
      return const Locale('ru');
    }
    
    return Locale(localeCode);
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    
    // Уведомляем об изменении
    onLocaleChanged?.call(Locale(languageCode));
  }
}
