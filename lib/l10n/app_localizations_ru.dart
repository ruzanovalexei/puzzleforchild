// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Мозаика. Животные';

  @override
  String get categorySelectionTitle => 'Выбор категории животных';

  @override
  String get petsCategory => 'Домашние животные';

  @override
  String get farmAnimalsCategory => 'Деревенские животные';

  @override
  String get wildAnimalsCategory => 'Дикие животные России';

  @override
  String get africanAnimalsCategory => 'Дикие животные Африки';

  @override
  String get settingsTitle => 'Настройки мозаики';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get backButton => 'назад';

  @override
  String get goToMain => 'На главную';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get errorLoadingImages => 'Ошибка загрузки списка изображений';

  @override
  String get retryButton => 'Повторить попытку';

  @override
  String get adNotAvailable => 'Реклама недоступна';

  @override
  String get adNotAvailableMessage =>
      'Нет рекламы для показа: проверьте соединение с интернетом или отключите блокировщик рекламы';

  @override
  String get adLoadError => 'Ошибка загрузки рекламы';

  @override
  String get okButton => 'Понятно';

  @override
  String get gridSize => 'Размер сетки';

  @override
  String get opacity => 'Прозрачность';

  @override
  String get congratulations => 'Ура! Получилось!';

  @override
  String availablePieces(int count) {
    return 'Доступные кусочки ($count)';
  }

  @override
  String get emptyCategory => 'В этой категории пока нет изображений';

  @override
  String get language => 'Язык';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'Английский';

  @override
  String get system => 'Системный';

  @override
  String get gridWillBe => 'Сетка будет';

  @override
  String get currentOpacity => 'Текущая прозрачность';
}
