import 'dart:convert'; // Import for json.decode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this line for rootBundle
import 'package:flutter_localizations/flutter_localizations.dart';
// Remove intl import if not used directly here, it's used via flutter_localizations

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'), // English
    Locale('fr'), // French
    Locale('ar'), // Arabic
  ];

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    // Now rootBundle should be recognized
    final jsonString =
        await rootBundle.loadString('assets/l10n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap =
        json.decode(jsonString); // Use json.decode from dart:convert
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.contains(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
