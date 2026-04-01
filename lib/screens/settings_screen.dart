import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzleforchild/l10n/app_localizations.dart';
import 'package:puzzleforchild/services/locale_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String puzzleGridSizeKey = 'puzzleGridSize';
  static const String puzzleOpacityKey = 'puzzleOpacity';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _gridSize = 4;
  double _puzzleOpacity = 0.1;
  String _validationMessage = '';
  bool _isSaveButtonEnabled = false;
  String _selectedLanguage = 'ru';
  final LocaleService _localeService = LocaleService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final int? savedGridSize = prefs.getInt(SettingsScreen.puzzleGridSizeKey);
    final double? savedOpacity = prefs.getDouble(SettingsScreen.puzzleOpacityKey);
    final String? savedLocale = prefs.getString('appLocale');
    
    setState(() {
      _gridSize = savedGridSize ?? 4;
      _puzzleOpacity = savedOpacity ?? 0.1;
      _selectedLanguage = savedLocale ?? 'ru';
    });
    _validateInput();
  }

  void _validateInput() {
    if (_gridSize < 3 || _gridSize > 7) {
      setState(() {
        _validationMessage = 'Значение должно быть от 3 до 7.';
        _isSaveButtonEnabled = false;
      });
    } else {
      setState(() {
        _validationMessage = '';
        _isSaveButtonEnabled = true;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SettingsScreen.puzzleGridSizeKey, _gridSize);
    await prefs.setDouble(SettingsScreen.puzzleOpacityKey, _puzzleOpacity);
    
    Navigator.pop(context);
  }

  void _onLanguageChanged(String? languageCode) {
    if (languageCode == null) return;
    
    setState(() {
      _selectedLanguage = languageCode;
    });
    
    _localeService.setLocale(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.gridSize),
            Slider(
              value: _gridSize.toDouble(),
              min: 3,
              max: 7,
              divisions: 4,
              label: _gridSize.toString(),
              onChanged: (double value) {
                setState(() {
                  _gridSize = value.toInt();
                  _validateInput();
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${l10n.gridWillBe} $_gridSize x $_gridSize',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (_validationMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  _validationMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 20),
            Text(l10n.opacity),
            Slider(
              value: _puzzleOpacity,
              min: 0.1,
              max: 0.5,
              divisions: 4,
              label: _puzzleOpacity.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() {
                  _puzzleOpacity = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${l10n.currentOpacity}: ${_puzzleOpacity.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.language),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(
                  value: 'ru',
                  label: Text(l10n.russian),
                ),
                ButtonSegment<String>(
                  value: 'en',
                  label: Text(l10n.english),
                ),
              ],
              selected: {_selectedLanguage},
              onSelectionChanged: (Set<String> selection) {
                _onLanguageChanged(selection.first);
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isSaveButtonEnabled ? _saveSettings : null,
                child: Text(l10n.saveButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}