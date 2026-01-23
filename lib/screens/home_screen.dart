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
      body: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Добавляем отступы по краям
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Равномерно распределяем кнопки
            crossAxisAlignment: CrossAxisAlignment.stretch, // Растягиваем кнопки по ширине
            children: [
              Expanded(
                  child:
                      _buildCategoryButton(context, 'Домашние животные', 'farm_animals')),
              const SizedBox(height: 16), // Отступ между кнопками
              Expanded(
                  child: _buildCategoryButton(context, 'Домашние питомцы', 'pets')),
              const SizedBox(height: 16), // Отступ между кнопками
              Expanded(
                  child: _buildCategoryButton(context, 'Дикие животные', 'wild_animals')),
              const SizedBox(height: 16), // Отступ между кнопками
              Expanded(
                  child: _buildCategoryButton(
                      context, 'Африканские животные', 'african_animals')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
      BuildContext context, String title, String categoryPath) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // remove minimumSize, as it conflicts with Expanded
        // minimumSize: const Size(200, 60), // Убрано, так как Expanded управляет размером
        // теперь ширина будет infinite
        minimumSize: const Size(
            double.infinity, 60), // Высота сохраняется, ширина на всю доступную
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategorySelectionScreen(
              categoryTitle: title,
              categoryAssetPath:
                  'assets/images/$categoryPath/', // Путь к изображениям категории
            ),
          ),
        );
      },
      child: Text(title),
    );
  }
}