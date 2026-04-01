// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mosaic. Animals';

  @override
  String get categorySelectionTitle => 'Select Animal Category';

  @override
  String get petsCategory => 'Pets';

  @override
  String get farmAnimalsCategory => 'Farm Animals';

  @override
  String get wildAnimalsCategory => 'Wild Animals of Russia';

  @override
  String get africanAnimalsCategory => 'Wild Animals of Africa';

  @override
  String get settingsTitle => 'Puzzle Settings';

  @override
  String get saveButton => 'Save';

  @override
  String get backButton => 'Back';

  @override
  String get goToMain => 'Main Menu';

  @override
  String get continueButton => 'Continue';

  @override
  String get errorLoadingImages => 'Error loading image list';

  @override
  String get retryButton => 'Retry';

  @override
  String get adNotAvailable => 'Ad not available';

  @override
  String get adNotAvailableMessage =>
      'No ad to display: check your internet connection or disable ad blocker';

  @override
  String get adLoadError => 'Ad loading error';

  @override
  String get okButton => 'OK';

  @override
  String get gridSize => 'Grid Size';

  @override
  String get opacity => 'Opacity';

  @override
  String get congratulations => 'Hooray! Done!';

  @override
  String availablePieces(int count) {
    return 'Available pieces ($count)';
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
  String get gridWillBe => 'Grid will be';

  @override
  String get currentOpacity => 'Current opacity';
}
