import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GhostSignalApp());
}

class GhostSignalApp extends StatelessWidget {
  const GhostSignalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GhostSignal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}