import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// Название приложения
  ///
  /// In ru, this message translates to:
  /// **'Мозаика. Животные'**
  String get appTitle;

  /// Заголовок экрана выбора категории
  ///
  /// In ru, this message translates to:
  /// **'Выбор категории животных'**
  String get categorySelectionTitle;

  /// Название категории домашних животных
  ///
  /// In ru, this message translates to:
  /// **'Домашние животные'**
  String get petsCategory;

  /// Название категории деревенских животных
  ///
  /// In ru, this message translates to:
  /// **'Деревенские животные'**
  String get farmAnimalsCategory;

  /// Название категории диких животных России
  ///
  /// In ru, this message translates to:
  /// **'Дикие животные России'**
  String get wildAnimalsCategory;

  /// Название категории диких животных Африки
  ///
  /// In ru, this message translates to:
  /// **'Дикие животные Африки'**
  String get africanAnimalsCategory;

  /// Заголовок экрана настроек
  ///
  /// In ru, this message translates to:
  /// **'Настройки мозаики'**
  String get settingsTitle;

  /// Текст кнопки сохранения
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get saveButton;

  /// Текст кнопки возврата
  ///
  /// In ru, this message translates to:
  /// **'назад'**
  String get backButton;

  /// Текст кнопки перехода на главный экран
  ///
  /// In ru, this message translates to:
  /// **'На главную'**
  String get goToMain;

  /// Текст кнопки продолжения
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continueButton;

  /// Сообщение об ошибке загрузки изображений
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки списка изображений'**
  String get errorLoadingImages;

  /// Текст кнопки повтора
  ///
  /// In ru, this message translates to:
  /// **'Повторить попытку'**
  String get retryButton;

  /// Заголовок диалога о недоступности рекламы
  ///
  /// In ru, this message translates to:
  /// **'Реклама недоступна'**
  String get adNotAvailable;

  /// Сообщение о недоступности рекламы
  ///
  /// In ru, this message translates to:
  /// **'Нет рекламы для показа: проверьте соединение с интернетом или отключите блокировщик рекламы'**
  String get adNotAvailableMessage;

  /// Заголовок диалога об ошибке загрузки рекламы
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки рекламы'**
  String get adLoadError;

  /// Текст кнопки OK
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get okButton;

  /// Настройка размера сетки пазла
  ///
  /// In ru, this message translates to:
  /// **'Размер сетки'**
  String get gridSize;

  /// Настройка прозрачности
  ///
  /// In ru, this message translates to:
  /// **'Прозрачность'**
  String get opacity;

  /// Поздравление при завершении пазла
  ///
  /// In ru, this message translates to:
  /// **'Ура! Получилось!'**
  String get congratulations;

  /// Количество доступных кусочков
  ///
  /// In ru, this message translates to:
  /// **'Доступные кусочки ({count})'**
  String availablePieces(int count);

  /// Сообщение о пустой категории
  ///
  /// In ru, this message translates to:
  /// **'В этой категории пока нет изображений'**
  String get emptyCategory;

  /// Настройка выбора языка
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// Русский язык
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get russian;

  /// Английский язык
  ///
  /// In ru, this message translates to:
  /// **'Английский'**
  String get english;

  /// Системный язык
  ///
  /// In ru, this message translates to:
  /// **'Системный'**
  String get system;

  /// Подпись размера сетки
  ///
  /// In ru, this message translates to:
  /// **'Сетка будет'**
  String get gridWillBe;

  /// Подпись прозрачности
  ///
  /// In ru, this message translates to:
  /// **'Текущая прозрачность'**
  String get currentOpacity;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
