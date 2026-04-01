import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

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
    Locale('ru'),
    Locale('zh')
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

  /// Русский
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get russian;

  /// English
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get english;

  /// 中文
  ///
  /// In ru, this message translates to:
  /// **'中文'**
  String get chinese;

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

  /// No description provided for @animal_canary.
  ///
  /// In ru, this message translates to:
  /// **'Канарейка'**
  String get animal_canary;

  /// No description provided for @animal_kapibara.
  ///
  /// In ru, this message translates to:
  /// **'Капибара'**
  String get animal_kapibara;

  /// No description provided for @animal_dwarf_rabbit.
  ///
  /// In ru, this message translates to:
  /// **'Карликовый кролик'**
  String get animal_dwarf_rabbit;

  /// No description provided for @animal_cat.
  ///
  /// In ru, this message translates to:
  /// **'Кошка'**
  String get animal_cat;

  /// No description provided for @animal_frog.
  ///
  /// In ru, this message translates to:
  /// **'Лягушка'**
  String get animal_frog;

  /// No description provided for @animal_guinea_pig.
  ///
  /// In ru, this message translates to:
  /// **'Морская свинка'**
  String get animal_guinea_pig;

  /// No description provided for @animal_tarantula.
  ///
  /// In ru, this message translates to:
  /// **'Паук-птицеед'**
  String get animal_tarantula;

  /// No description provided for @animal_parrot.
  ///
  /// In ru, this message translates to:
  /// **'Попугай'**
  String get animal_parrot;

  /// No description provided for @animal_fish.
  ///
  /// In ru, this message translates to:
  /// **'Рыбка'**
  String get animal_fish;

  /// No description provided for @animal_dog.
  ///
  /// In ru, this message translates to:
  /// **'Собака'**
  String get animal_dog;

  /// No description provided for @animal_snail.
  ///
  /// In ru, this message translates to:
  /// **'Улитка'**
  String get animal_snail;

  /// No description provided for @animal_hamster.
  ///
  /// In ru, this message translates to:
  /// **'Хомяк'**
  String get animal_hamster;

  /// No description provided for @animal_ferret.
  ///
  /// In ru, this message translates to:
  /// **'Хорек'**
  String get animal_ferret;

  /// No description provided for @animal_turtle.
  ///
  /// In ru, this message translates to:
  /// **'Черепаха'**
  String get animal_turtle;

  /// No description provided for @animal_chinchilla.
  ///
  /// In ru, this message translates to:
  /// **'Шиншилла'**
  String get animal_chinchilla;

  /// No description provided for @animal_lizard.
  ///
  /// In ru, this message translates to:
  /// **'Ящерица'**
  String get animal_lizard;

  /// No description provided for @animal_ram.
  ///
  /// In ru, this message translates to:
  /// **'Баран'**
  String get animal_ram;

  /// No description provided for @animal_bull.
  ///
  /// In ru, this message translates to:
  /// **'Бык'**
  String get animal_bull;

  /// No description provided for @animal_goose.
  ///
  /// In ru, this message translates to:
  /// **'Гусь'**
  String get animal_goose;

  /// No description provided for @animal_turkey.
  ///
  /// In ru, this message translates to:
  /// **'Индюк'**
  String get animal_turkey;

  /// No description provided for @animal_goat.
  ///
  /// In ru, this message translates to:
  /// **'Коза'**
  String get animal_goat;

  /// No description provided for @animal_cow.
  ///
  /// In ru, this message translates to:
  /// **'Корова'**
  String get animal_cow;

  /// No description provided for @animal_chicken.
  ///
  /// In ru, this message translates to:
  /// **'Курица'**
  String get animal_chicken;

  /// No description provided for @animal_horse.
  ///
  /// In ru, this message translates to:
  /// **'Лошадь'**
  String get animal_horse;

  /// No description provided for @animal_sheep.
  ///
  /// In ru, this message translates to:
  /// **'Овца'**
  String get animal_sheep;

  /// No description provided for @animal_donkey.
  ///
  /// In ru, this message translates to:
  /// **'Осел'**
  String get animal_donkey;

  /// No description provided for @animal_rooster.
  ///
  /// In ru, this message translates to:
  /// **'Петух'**
  String get animal_rooster;

  /// No description provided for @animal_pig.
  ///
  /// In ru, this message translates to:
  /// **'Свинья'**
  String get animal_pig;

  /// No description provided for @animal_duck.
  ///
  /// In ru, this message translates to:
  /// **'Утка'**
  String get animal_duck;

  /// No description provided for @animal_pheasant.
  ///
  /// In ru, this message translates to:
  /// **'Фазан'**
  String get animal_pheasant;

  /// No description provided for @animal_squirrel.
  ///
  /// In ru, this message translates to:
  /// **'Белка'**
  String get animal_squirrel;

  /// No description provided for @animal_polar_bear.
  ///
  /// In ru, this message translates to:
  /// **'Белый медведь'**
  String get animal_polar_bear;

  /// No description provided for @animal_brown_bear.
  ///
  /// In ru, this message translates to:
  /// **'Бурый медведь'**
  String get animal_brown_bear;

  /// No description provided for @animal_wolf.
  ///
  /// In ru, this message translates to:
  /// **'Волк'**
  String get animal_wolf;

  /// No description provided for @animal_stoat.
  ///
  /// In ru, this message translates to:
  /// **'Горностай'**
  String get animal_stoat;

  /// No description provided for @animal_snowshoe_hare.
  ///
  /// In ru, this message translates to:
  /// **'Заяц-беляк'**
  String get animal_snowshoe_hare;

  /// No description provided for @animal_european_hare.
  ///
  /// In ru, this message translates to:
  /// **'Заяц-русак'**
  String get animal_european_hare;

  /// No description provided for @animal_wild_boar.
  ///
  /// In ru, this message translates to:
  /// **'Кабан'**
  String get animal_wild_boar;

  /// No description provided for @animal_roe_deer.
  ///
  /// In ru, this message translates to:
  /// **'Косуля'**
  String get animal_roe_deer;

  /// No description provided for @animal_fox.
  ///
  /// In ru, this message translates to:
  /// **'Лисица'**
  String get animal_fox;

  /// No description provided for @animal_moose.
  ///
  /// In ru, this message translates to:
  /// **'Лось'**
  String get animal_moose;

  /// No description provided for @animal_walrus.
  ///
  /// In ru, this message translates to:
  /// **'Морж'**
  String get animal_walrus;

  /// No description provided for @animal_lynx.
  ///
  /// In ru, this message translates to:
  /// **'Рысь'**
  String get animal_lynx;

  /// No description provided for @animal_reindeer.
  ///
  /// In ru, this message translates to:
  /// **'Северный олень'**
  String get animal_reindeer;

  /// No description provided for @animal_ground_squirrel.
  ///
  /// In ru, this message translates to:
  /// **'Суслик'**
  String get animal_ground_squirrel;

  /// No description provided for @animal_siberian_tiger.
  ///
  /// In ru, this message translates to:
  /// **'Тигр амурский'**
  String get animal_siberian_tiger;

  /// No description provided for @animal_hippo.
  ///
  /// In ru, this message translates to:
  /// **'Бегемот'**
  String get animal_hippo;

  /// No description provided for @animal_buffalo.
  ///
  /// In ru, this message translates to:
  /// **'Буйвол'**
  String get animal_buffalo;

  /// No description provided for @animal_camel.
  ///
  /// In ru, this message translates to:
  /// **'Верблюд'**
  String get animal_camel;

  /// No description provided for @animal_cheetah.
  ///
  /// In ru, this message translates to:
  /// **'Гепард'**
  String get animal_cheetah;

  /// No description provided for @animal_hyena.
  ///
  /// In ru, this message translates to:
  /// **'Гиена'**
  String get animal_hyena;

  /// No description provided for @animal_gorilla.
  ///
  /// In ru, this message translates to:
  /// **'Горилла'**
  String get animal_gorilla;

  /// No description provided for @animal_zebra.
  ///
  /// In ru, this message translates to:
  /// **'Зебра'**
  String get animal_zebra;

  /// No description provided for @animal_crocodile.
  ///
  /// In ru, this message translates to:
  /// **'Крокодил'**
  String get animal_crocodile;

  /// No description provided for @animal_lion.
  ///
  /// In ru, this message translates to:
  /// **'Лев'**
  String get animal_lion;

  /// No description provided for @animal_lemur.
  ///
  /// In ru, this message translates to:
  /// **'Лемур'**
  String get animal_lemur;

  /// No description provided for @animal_leopard.
  ///
  /// In ru, this message translates to:
  /// **'Леопард'**
  String get animal_leopard;

  /// No description provided for @animal_rhino.
  ///
  /// In ru, this message translates to:
  /// **'Носорог'**
  String get animal_rhino;

  /// No description provided for @animal_elephant.
  ///
  /// In ru, this message translates to:
  /// **'Слон'**
  String get animal_elephant;

  /// No description provided for @animal_ostrich.
  ///
  /// In ru, this message translates to:
  /// **'Страус'**
  String get animal_ostrich;

  /// No description provided for @animal_meerkat.
  ///
  /// In ru, this message translates to:
  /// **'Сурикат'**
  String get animal_meerkat;

  /// No description provided for @animal_chimpanzee.
  ///
  /// In ru, this message translates to:
  /// **'Шимпанзе'**
  String get animal_chimpanzee;
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
      <String>['en', 'ru', 'zh'].contains(locale.languageCode);

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
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
