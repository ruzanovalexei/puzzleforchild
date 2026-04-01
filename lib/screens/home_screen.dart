import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puzzleforchild/screens/category_selection_screen.dart';
import 'package:puzzleforchild/screens/settings_screen.dart';
import 'package:puzzleforchild/l10n/app_localizations.dart';
import 'package:puzzleforchild/services/locale_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.categorySelectionTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onLanguageSaved: (languageCode) {
                      // Применяем язык через LocaleService callback
                      LocaleService.onLocaleChanged?.call(Locale(languageCode));
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildCategoryButton(context, l10n.petsCategory, 'pets'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildCategoryButton(context, l10n.farmAnimalsCategory, 'farm_animals'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildCategoryButton(context, l10n.wildAnimalsCategory, 'wild_animals'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildCategoryButton(context, l10n.africanAnimalsCategory, 'african_animals'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String title, String categoryPath) {
    return FutureBuilder<List<String>>(
      future: _loadImagesForCategory(categoryPath), // Используем новый метод
      builder: (context, snapshot) {
        String? randomImagePath;
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.isNotEmpty) {
          final List<String> images = snapshot.data!;
          final random = Random();
          randomImagePath = images[random.nextInt(images.length)];
        }

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            textStyle: const TextStyle(fontSize: 20),
            padding: const EdgeInsets.all(8.0),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategorySelectionScreen(
                  categoryTitle: title,
                  categoryAssetPath: 'assets/images/$categoryPath/',
                ),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (randomImagePath != null)
                Expanded(
                  child: Image.asset(
                    randomImagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  // Новый метод для загрузки списка изображений из текстового файла
  Future<List<String>> _loadImagesForCategory(String categoryPath) async {
    try {
      final String assetListFilePath = 'assets/asset_lists/$categoryPath.txt';
      final String assetsContent = await rootBundle.loadString(assetListFilePath);

      // Разбиваем содержимое по строкам и отфильтровываем пустые
      final List<String> assets = assetsContent
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      return assets;
    } catch (e) {
      // print('Error loading asset list for category $categoryPath: $e');
      return []; // Возвращаем пустой список в случае ошибки
    }
  }
}