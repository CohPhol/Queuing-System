import 'package:flutter/material.dart';

import '../features/home/home_view.dart';
import '../features/players/players_view.dart';
import '../features/settings/settings_view.dart';

import 'theme/theme_controller.dart';
import '../application/controllers/player_controller.dart';

class MainShell extends StatefulWidget {
  final ThemeController themeController;
  final PlayerController playerController;

  const MainShell({
    super.key,
    required this.themeController,
    required this.playerController,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      HomeView(playerController: widget.playerController),
      const PlayersView(),
      SettingsView(themeController: widget.themeController),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Queue System",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          AnimatedBuilder(
            animation: widget.themeController,
            builder: (context, _) {
              final isDark = widget.themeController.isDark;

              return IconButton(
                tooltip: "Toggle Theme",
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  widget.themeController.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Players'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),

          const VerticalDivider(width: 1),

          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
