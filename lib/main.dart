import 'package:flutter/material.dart';
import 'package:My_new_puzzle/screens/puzzle_screen.dart';

void main() {
  runApp(const PuzzleApp());
}

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Детский пазл',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PuzzleScreen(),
    );
  }
}