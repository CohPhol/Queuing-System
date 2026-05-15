import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  final List<List<String>> teams;

  const MatchCard({
    super.key,
    required this.title,
    required this.actionText,
    required this.onAction,
    required this.teams,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: onAction, child: Text(actionText)),
              ],
            ),

            const SizedBox(height: 10),

            // TEAMS
            ...teams.map((pair) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(child: _box(pair[0])),
                    const SizedBox(width: 8),
                    Expanded(child: _box(pair[1])),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _box(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text),
    );
  }
}
