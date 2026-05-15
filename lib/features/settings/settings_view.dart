import 'package:flutter/material.dart';
import '../../app/theme/theme_controller.dart';

class SettingsView extends StatelessWidget {
  final ThemeController themeController;

  const SettingsView({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final isDark = themeController.isDark;

        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                themeController.toggleTheme();
              },
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              label: Text(
                isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
              ),
            ),
          ),
        );
      },
    );
  }
}
