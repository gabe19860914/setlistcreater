import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const SetlistApp());

class SetlistApp extends StatelessWidget {
  const SetlistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Setlist Creator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}