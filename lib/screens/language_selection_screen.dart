import 'package:flutter/material.dart';
import 'package:puzzleforchild/services/locale_service.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final Function(Locale) onLanguageSelected;

  const LanguageSelectionScreen({
    super.key,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Выберите язык',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Select language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Dil seçin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildLanguageButton(
                context: context,
                languageCode: 'ru',
                label: 'Русский',
                flag: '🇷🇺',
              ),
              const SizedBox(height: 16),
              _buildLanguageButton(
                context: context,
                languageCode: 'en',
                label: 'English',
                flag: '🇬🇧',
              ),
              const SizedBox(height: 16),
              _buildLanguageButton(
                context: context,
                languageCode: 'tr',
                label: 'Türkçe',
                flag: '🇹🇷',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required BuildContext context,
    required String languageCode,
    required String label,
    required String flag,
  }) {
    return ElevatedButton(
      onPressed: () async {
        final locale = Locale(languageCode);
        await LocaleService().setLocale(languageCode);
        await LocaleService().setFirstLaunchComplete();
        onLanguageSelected(locale);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            flag,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
