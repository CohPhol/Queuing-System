import 'package:flutter/material.dart';
import '../shared/match_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // =========================
          // LEFT: PLAYER LIST
          // =========================
          Container(
            width: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              itemCount: 12,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("Player ${index + 1}"),
                  subtitle: const Text("Skill: Intermediate"),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // =========================
          // RIGHT SIDE (COURTS + QUEUE)
          // =========================
          Expanded(
            child: Column(
              children: [
                // COURTS
                Expanded(
                  child: ListView(
                    children: [
                      MatchCard(
                        title: "Court 1",
                        actionText: "End Game",
                        onAction: () {},
                        teams: const [
                          ["Team A P1", "Team B P1"],
                          ["Team A P2", "Team B P2"],
                        ],
                      ),

                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text("Add Court"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // QUEUE
                Expanded(
                  child: ListView(
                    children: [
                      MatchCard(
                        title: "Queue 1",
                        actionText: "Transfer to Court",
                        onAction: () {},
                        teams: const [
                          ["Team A P1", "Team B P1"],
                          ["Team A P2", "Team B P2"],
                        ],
                      ),

                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text("Add Queue"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
