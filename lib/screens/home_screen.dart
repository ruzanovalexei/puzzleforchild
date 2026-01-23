import 'package:flutter/material.dart';
import 'package:puzzleforchild/screens/category_selection_screen.dart';
import 'package:puzzleforchild/screens/settings_screen.dart'; // <--- Импорт SettingsScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор категории пазлов'),
        actions: [
          IconButton( // <--- Это кнопка
            icon: const Icon(Icons.settings), // <--- Иконка шестеренки
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()), // <--- Вызов SettingsScreen
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryButton(context, 'Домашние животные', 'farm_animals'),
            _buildCategoryButton(context, 'Домашние питомцы', 'pets'),
            _buildCategoryButton(context, 'Дикие животные', 'wild_animals'),
            _buildCategoryButton(context, 'Африканские животные', 'african_animals'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String title, String categoryPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 60),
          textStyle: const TextStyle(fontSize: 20),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategorySelectionScreen(
                categoryTitle: title,
                categoryAssetPath: 'assets/images/$categoryPath/', // Путь к изображениям категории
              ),
            ),
          );
        },
        child: Text(title),
      ),
    );
  }
}