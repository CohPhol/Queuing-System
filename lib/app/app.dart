import 'package:flutter/material.dart';
import 'main_shell.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import '../application/controllers/player_controller.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeController themeController = ThemeController();
  final PlayerController playerController = PlayerController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: MainShell(
            themeController: themeController,
            playerController: playerController,
          ),
        );
      },
    );
  }
}
