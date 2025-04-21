import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import main to access MyApp.setLocale

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Locale? _selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize with current app locale
    _selectedLocale ??= Localizations.localeOf(context);
  }

  // Helper to get language name from locale
  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      default:
        return locale.languageCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use translation for the title
        title: Text(AppLocalizations.of(context)?.translate('settingsTitle') ?? 'Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              AppLocalizations.of(context)?.translate('language') ?? 'Language',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButton<Locale>(
              value: _selectedLocale,
              isExpanded: true, // Make dropdown take full width
              icon: const Icon(Icons.arrow_drop_down),
              items: AppLocalizations.supportedLocales.map((Locale locale) {
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(_getLanguageName(locale)),
                );
              }).toList(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  setState(() {
                    _selectedLocale = newLocale;
                  });
                  // Call the static method in MyApp to update the locale globally
                  MyApp.setLocale(context, newLocale);
                }
              },
            ),
            // Add other settings here...
          ],
        ),
      ),
    );
  }
}