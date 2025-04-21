import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
// Import settings screen if you navigate to it from here
// import 'screens/settings_screen.dart';

void main() {
  // Ensure widgets are initialized before loading preferences
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Make MyApp StatefulWidget
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  // Add this method to allow descendants to change the locale
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale(); // Load saved locale on init
  }

  // Method to load saved locale
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  // Method to change and save locale
  void changeLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Control', // Consider localizing this later if needed
      locale: _locale, // Use the state variable for locale
      localizationsDelegates: const [
        // Make delegates const
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // localeResolutionCallback can often be simplified or removed
      // if you handle the initial locale loading as above.
      // Flutter automatically selects the best match or the first supported locale.
      // localeResolutionCallback: (locale, supportedLocales) {
      //   if (_locale != null) return _locale; // Prioritize saved locale
      //   for (var supportedLocale in supportedLocales) {
      //     if (supportedLocale.languageCode == locale?.languageCode) {
      //       return supportedLocale;
      //     }
      //   }
      //   return supportedLocales.first; // Default fallback
      // },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      // You might want routes if you have multiple screens
      // routes: {
      //   '/': (context) => const HomeScreen(),
      //   '/settings': (context) => const SettingsScreen(),
      // },
    );
  }
}
