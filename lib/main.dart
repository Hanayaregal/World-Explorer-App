// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';  // ← YOUR MAIN SCREEN

void main() {
  runApp(const WorldExplorerApp());
}

class WorldExplorerApp extends StatelessWidget {
  const WorldExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),  // ← THIS MUST BE YOUR HomeScreen
    );
  }
}