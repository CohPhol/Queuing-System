import 'package:flutter/material.dart';

import '../features/home/home_view.dart';
import '../features/players/players_view.dart';
import '../features/settings/settings_view.dart';

import 'theme/theme_controller.dart';
import '../application/controllers/player_controller.dart';
import '../application/controllers/court_controller.dart';
import '../application/controllers/queue_controller.dart';

class MainShell extends StatefulWidget {
  final ThemeController themeController;
  final PlayerController playerController;
  final CourtController courtController;
  final QueueController queueController;

  const MainShell({
    super.key,
    required this.themeController,
    required this.playerController,
    required this.courtController,
    required this.queueController,
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
      HomeView(
        playerController: widget.playerController,
        courtController: widget.courtController,
        queueController: widget.queueController,
      ),
      const PlayersView(),
      SettingsView(themeController: widget.themeController),
    ];
  }

  Widget _buildNavigationTab({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text(
          'Queue System',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          _buildNavigationTab(
            index: 0,
            label: 'Home',
            icon: Icons.home_outlined,
          ),
          _buildNavigationTab(
            index: 1,
            label: 'Players',
            icon: Icons.people_outline,
          ),
          _buildNavigationTab(
            index: 2,
            label: 'Settings',
            icon: Icons.settings_outlined,
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: widget.themeController,
            builder: (context, _) {
              final isDark = widget.themeController.isDark;

              return IconButton(
                tooltip: 'Toggle Theme',
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: widget.themeController.toggleTheme,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: selectedIndex, children: pages),
    );
  }
}
