import 'package:flutter/material.dart';

import 'main_shell.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

import '../application/controllers/player_controller.dart';
import '../application/controllers/court_controller.dart';
import '../application/controllers/queue_controller.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeController themeController = ThemeController();
  final PlayerController playerController = PlayerController();
  final CourtController courtController = CourtController();
  final QueueController queueController = QueueController();

  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.wait([
      playerController.initialize(),
      courtController.initialize(),
      queueController.initialize(),
      themeController.initialize(),
    ]);
  }

  @override
  void dispose() {
    themeController.dispose();
    playerController.dispose();
    courtController.dispose();
    queueController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to load saved app data.',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your saved data has not intentionally been '
                        'cleared. Check the error and try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _initialization = _initializeApp();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

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
                courtController: courtController,
                queueController: queueController,
              ),
            );
          },
        );
      },
    );
  }
}
