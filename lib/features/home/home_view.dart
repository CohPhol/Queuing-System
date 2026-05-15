import 'package:flutter/material.dart';
import '../shared/match_card.dart';

import '../../application/controllers/player_controller.dart';
import '../../domain/models/player.dart';
import '../../domain/enums/skill_level.dart';
import '../../domain/enums/payment_status.dart';
import '../../domain/enums/player_status.dart';
import '../../domain/enums/player_availability.dart';
import '../players/widgets/player_card.dart';

class HomeView extends StatefulWidget {
  final PlayerController playerController;

  const HomeView({super.key, required this.playerController});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 1000) return 1; // mobile / narrow
    if (width < 2000) return 2; // tablet / small desktop
    return 3; // wide screen
  }

  double _getAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 1000) return 2.6; // mobile/narrow
    if (width < 1600) return 3.2; // normal desktop
    return 4.0; // wide screen
  }

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
          // LEFT: PLAYER LIST (1/3)
          // =========================
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // ===================== HEADER =====================
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedBuilder(
                      animation: widget.playerController,
                      builder: (context, _) {
                        final count = widget.playerController.players.length;

                        return Column(
                          children: [
                            // ================= TOP CONTROL ROW =================
                            Row(
                              children: [
                                // TITLE
                                Text(
                                  "Players ($count)",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // SEARCH BAR
                                Expanded(
                                  child: SizedBox(
                                    height: 32,
                                    child: TextField(
                                      onChanged: (value) {
                                        // TODO: connect to controller filter
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Search player...",
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          size: 18,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 0,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // ADD BUTTON
                                SizedBox(
                                  height: 32,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      widget.playerController.addPlayer(
                                        Player(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString(),
                                          name:
                                              "Player ${widget.playerController.players.length + 1}",
                                          skillLevel: SkillLevel.beginner,
                                          gamesPlayed: 0,
                                          wins: 0,
                                          paymentStatus: PaymentStatus.unpaid,
                                          status: PlayerStatus.idle,
                                          availability:
                                              PlayerAvailability.present,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text("Add"),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  // ===================== LIST =====================
                  Expanded(
                    child: AnimatedBuilder(
                      animation: widget.playerController,
                      builder: (context, _) {
                        final players = widget.playerController.players;

                        return GridView.builder(
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width < 1000 ? 4 : 6,
                          ),
                          itemCount: players.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _getCrossAxisCount(context),
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                childAspectRatio: _getAspectRatio(context),
                              ),
                          itemBuilder: (context, index) {
                            final player = players[index];

                            return PlayerCard(
                              player: player,
                              onEdit: () => _showEditDialog(player),
                              onDelete: () => widget.playerController
                                  .deletePlayer(player.id),
                              onTogglePayment: () => widget.playerController
                                  .togglePayment(player.id),
                              onToggleAvailability: () => widget
                                  .playerController
                                  .toggleAvailability(player.id),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // =========================
          // RIGHT SIDE (2/3)
          // =========================
          Expanded(
            flex: 2,
            child: Column(
              children: [
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
