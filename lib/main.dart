import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puzzlebirds/screens/home_screen.dart'; // Предположим, ProjectName - это название вашего проекта в pubspec.yaml

void main() async {
  runApp(const MyApp());
    // Закрепляем портретную ориентацию
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мозаика. Животные',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // Запускаем домашний экран
    );
  }
}