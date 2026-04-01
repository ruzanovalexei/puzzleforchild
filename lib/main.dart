import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:puzzleforchild/screens/home_screen.dart';
import 'package:puzzleforchild/screens/language_selection_screen.dart';
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
  bool _isFirstLaunch = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    
    // Регистрируем callback для изменения локали
    LocaleService.onLocaleChanged = (locale) {
      setState(() {
        _locale = locale;
      });
    };
  }

  Future<void> _initializeApp() async {
    final isFirst = await _localeService.isFirstLaunch();
    final locale = await _localeService.getLocale();
    
    if (mounted) {
      setState(() {
        _isFirstLaunch = isFirst;
        _locale = locale;
        _isLoading = false;
      });
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _onLanguageSelected(Locale locale) {
    setState(() {
      _locale = locale;
      _isFirstLaunch = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        title: 'Мозаика. Животные',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Microsoft YaHei',
        ),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Мозаика. Животные',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Microsoft YaHei',
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleService.supportedLocales,
      home: _isFirstLaunch 
          ? LanguageSelectionScreen(onLanguageSelected: _onLanguageSelected)
          : const HomeScreen(),
    );
  }
}