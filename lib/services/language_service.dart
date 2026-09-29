import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../l10n/app_translations.dart';

class LanguageModel {
  final String code;
  final String name;
  final String nativeName;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

class LanguageService {
  static final LanguageService instance = LanguageService._internal();
  factory LanguageService() => instance;
  LanguageService._internal();

  static const String _prefLanguageKey = 'bharat_mitra_selected_language';

  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(code: 'en', name: 'English', nativeName: 'English'),
    LanguageModel(code: 'hi', name: 'Hindi', nativeName: 'Hindi'),
    LanguageModel(code: 'bn', name: 'Bengali', nativeName: 'Bangla'),
    LanguageModel(code: 'ta', name: 'Tamil', nativeName: 'Tamil'),
    LanguageModel(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    LanguageModel(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    LanguageModel(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    LanguageModel(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
  ];

  String _currentLanguageCode = 'en';
  String get currentLanguageCode => _currentLanguageCode;

  /// Initialize and load saved language from SharedPreferences (Default 'en')
  Future<String> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguageCode = prefs.getString(_prefLanguageKey) ?? 'en';
      AppTranslations.setLanguage(_currentLanguageCode);
    } catch (e) {
      _currentLanguageCode = 'en';
      AppTranslations.setLanguage('en');
    }
    return _currentLanguageCode;
  }

  /// Change and persist selected language code
  Future<void> changeLanguage(BuildContext context, String code) async {
    _currentLanguageCode = code;
    AppTranslations.setLanguage(code);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLanguageKey, code);
    } catch (_) {}

    try {
      await context.setLocale(Locale(code));
    } catch (_) {}
  }

  /// Translate a key through AppTranslations / EasyLocalization fallback
  String translate(String key) {
    return AppTranslations.tr(key);
  }
}
