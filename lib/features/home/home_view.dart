import 'package:flutter/material.dart';
import '../shared/match_card.dart';

import '../../application/controllers/player_controller.dart';
import '../../domain/models/player.dart';
import '../../domain/enums/skill_level.dart';
import '../../domain/enums/payment_status.dart';
import '../../domain/enums/player_status.dart';

class HomeView extends StatefulWidget {
  final PlayerController playerController;

  const HomeView({super.key, required this.playerController});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
            child: Column(
              children: [
                // =====================
                // ADD BUTTON
                // =====================
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedBuilder(
                    animation: widget.playerController,
                    builder: (context, _) {
                      final count = widget.playerController.players.length;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Players: $count",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          ElevatedButton.icon(
                            onPressed: () {
                              widget.playerController.addPlayer(
                                Player(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  name:
                                      "Player ${widget.playerController.players.length + 1}",
                                  skillLevel: SkillLevel.beginner,
                                  gamesPlayed: 0,
                                  wins: 0,
                                  paymentStatus: PaymentStatus.unpaid,
                                  status: PlayerStatus.idle,
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Add Player"),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const Divider(height: 1),

                // =====================
                // PLAYER LIST
                // =====================
                Expanded(
                  child: AnimatedBuilder(
                    animation: widget.playerController,
                    builder: (context, _) {
                      final players = widget.playerController.players;

                      return ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final player = players[index];

                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(player.name),
                            subtitle: Text(player.skillLevel.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                widget.playerController.deletePlayer(player.id);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
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
