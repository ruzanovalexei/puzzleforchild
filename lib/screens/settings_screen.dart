import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Импортируем shared_preferences

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String puzzleGridSizeKey = 'puzzleGridSize'; // Ключ для сохранения настройки

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _gridSizeController = TextEditingController();
  String _validationMessage = '';
  bool _isSaveButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _gridSizeController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _gridSizeController.removeListener(_validateInput);
    _gridSizeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final int? savedGridSize = prefs.getInt(SettingsScreen.puzzleGridSizeKey);
    if (savedGridSize != null) {
      _gridSizeController.text = savedGridSize.toString();
    } else {
      _gridSizeController.text = '4'; // Значение по умолчанию
    }
    _validateInput(); // Проверить после загрузки
  }

  void _validateInput() {
    final String text = _gridSizeController.text;
    if (text.isEmpty) {
      setState(() {
        _validationMessage = 'Значение не может быть пустым.';
        _isSaveButtonEnabled = false;
      });
      return;
    }

    final int? value = int.tryParse(text);
    if (value == null) {
      setState(() {
        _validationMessage = 'Пожалуйста, введите число.';
        _isSaveButtonEnabled = false;
      });
      return;
    }

    if (value < 4 || value > 7) {
      setState(() {
        _validationMessage = 'Значение должно быть от 4 до 7.';
        _isSaveButtonEnabled = false;
      });
      return;
    }

    setState(() {
      _validationMessage = '';
      _isSaveButtonEnabled = true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final int newGridSize = int.parse(_gridSizeController.text);
    await prefs.setInt(SettingsScreen.puzzleGridSizeKey, newGridSize);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки сохранены!')),
    );
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
            TextField(
              controller: _gridSizeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Размерность сетки (A)',
                hintText: 'Введите число от 4 до 7',
                suffixText: (_gridSizeController.text.isNotEmpty && int.tryParse(_gridSizeController.text) != null)
                    ? 'Сетка будет ${_gridSizeController.text}x${_gridSizeController.text}'
                    : null,
                errorText: _validationMessage.isNotEmpty ? _validationMessage : null,
                border: const OutlineInputBorder(),
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