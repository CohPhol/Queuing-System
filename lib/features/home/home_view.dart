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
  void _showEditDialog(Player player) {
    final nameController = TextEditingController(text: player.name);

    SkillLevel selectedSkill = player.skillLevel;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Player"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<SkillLevel>(
                initialValue: selectedSkill,
                decoration: const InputDecoration(
                  labelText: "Skill Level",
                  border: OutlineInputBorder(),
                ),
                items: SkillLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedSkill = value;
                  });
                },
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                widget.playerController.updatePlayer(
                  player.copyWith(
                    name: nameController.text,
                    skillLevel: selectedSkill,
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

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
                            subtitle: Text(player.skillLevel.label),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(player);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    widget.playerController.deletePlayer(
                                      player.id,
                                    );
                                  },
                                ),
                              ],
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
