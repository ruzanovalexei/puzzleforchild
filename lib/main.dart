import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:puzzleforchild/screens/home_screen.dart';
import 'package:puzzleforchild/l10n/app_localizations.dart';
import 'package:puzzleforchild/services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Закрепляем портретную ориентацию
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ru');
  final LocaleService _localeService = LocaleService();

  @override
  void initState() {
    super.initState();
    _loadLocale();
    
    // Регистрируем callback для изменения локали
    LocaleService.onLocaleChanged = (locale) {
      setState(() {
        _locale = locale;
      });
    };
  }

  Future<void> _loadLocale() async {
    final locale = await _localeService.getLocale();
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мозаика. Животные',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleService.supportedLocales,
      home: const HomeScreen(),
    );
  }
}