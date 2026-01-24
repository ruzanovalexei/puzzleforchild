import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Импортируем shared_preferences

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String puzzleGridSizeKey = 'puzzleGridSize'; // Ключ для сохранения настройки
  static const String puzzleOpacityKey = 'puzzleOpacity'; // Новый ключ для сохранения настройки прозрачности

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // final TextEditingController _gridSizeController = TextEditingController(); // Больше не нужно
  int _gridSize = 4; // Будем хранить текущее значение размера сетки
  double _puzzleOpacity = 0.1; // Для прозрачности
  String _validationMessage = '';
  bool _isSaveButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // _gridSizeController.addListener(_validateInput); // Больше не нужно
  }

  @override
  void dispose() {
    // _gridSizeController.removeListener(_validateInput); // Больше не нужно
    // _gridSizeController.dispose(); // Больше не нужно
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final int? savedGridSize = prefs.getInt(SettingsScreen.puzzleGridSizeKey);
    final double? savedOpacity = prefs.getDouble(SettingsScreen.puzzleOpacityKey); // Загружаем прозрачность
    setState(() {
      _gridSize = savedGridSize ?? 4; // Устанавливаем _gridSize
      _puzzleOpacity = savedOpacity ?? 0.1; // Устанавливаем _puzzleOpacity по умолчанию
    });
    _validateInput(); // Проверить после загрузки
  }

  void _validateInput() {
    // Валидация будет происходить по _gridSize
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

  // void _incrementGridSize() {
  //   setState(() {
  //     if (_gridSize < 7) {
  //       _gridSize++;
  //     }
  //     _validateInput();
  //   });
  // }

  // void _decrementGridSize() {
  //   setState(() {
  //     if (_gridSize > 3) {
  //       _gridSize--;
  //     }
  //     _validateInput();
  //   });
  // }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SettingsScreen.puzzleGridSizeKey, _gridSize);
    await prefs.setDouble(SettingsScreen.puzzleOpacityKey, _puzzleOpacity); // Сохраняем прозрачность

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Настройки сохранены!')),
    // );
    Navigator.pop(context); // Возвращаемся на предыдущий экран
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки пазла'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Размерность сетки (количество клеток по горизонтали и вертикали):'),
            Slider(
              value: _gridSize.toDouble(),
              min: 3,
              max: 7,
              divisions: 4, // Для значений 3, 4, 5, 6, 7
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
                'Сетка будет ${_gridSize}x${_gridSize}',
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
            Text('Прозрачность фоновой картинки:'),
            Slider(
              value: _puzzleOpacity,
              min: 0.1,
              max: 0.5,
              divisions: 4, // чтобы получить 0.1, 0.2, 0.3, 0.4, 0.5
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
                'Текущая прозрачность: ${_puzzleOpacity.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isSaveButtonEnabled ? _saveSettings : null,
                child: const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}