import 'package:flutter/material.dart';
import 'package:puzzleforchild/screens/home_screen.dart'; // Предположим, ProjectName - это название вашего проекта в pubspec.yaml

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Детский Пазл',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // Запускаем домашний экран
    );
  }
}