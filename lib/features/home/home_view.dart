import 'package:flutter/material.dart';

import '../../domain/models/queue_group.dart';
import '../shared/match_card.dart';
import '../shared/queue_card.dart';
import '../players/widgets/player_card.dart';

import '../../application/controllers/player_controller.dart';
import '../../application/controllers/court_controller.dart';
import '../../application/controllers/queue_controller.dart';

import '../../domain/models/queue_entry.dart';
import '../../domain/models/player.dart';
import '../../domain/enums/skill_level.dart';
import '../../domain/enums/payment_status.dart';
import '../../domain/enums/player_status.dart';
import '../../domain/enums/player_availability.dart';
import '../../domain/enums/queue_priority.dart';
import '../../domain/enums/queue_team.dart';

class HomeView extends StatefulWidget {
  final PlayerController playerController;
  final CourtController courtController;
  final QueueController queueController;

  const HomeView({
    super.key,
    required this.playerController,
    required this.courtController,
    required this.queueController,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _searchQuery = '';

  Listenable get _playerStateListenable => Listenable.merge([
    widget.playerController,
    widget.courtController,
    widget.queueController,
  ]);

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 1300) return 1;
    return 2;
  }

  double _getAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 1300) return 5.5;
    return 3.2;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  // Determine whether the player is assigned to any court.
  bool _isPlayerOnCourt(Player player) {
    return widget.courtController.courts.any((court) {
      return [
        ...court.teamA,
        ...court.teamB,
      ].any((courtPlayer) => courtPlayer.id == player.id);
    });
  }

  // Determine whether the player is in any queue.
  bool _isPlayerQueued(Player player) {
    return widget.queueController.queues.any((queueGroup) {
      return queueGroup.queue.entries.any(
        (entry) => entry.player.id == player.id,
      );
    });
  }

  // Derive the display status without modifying or saving Player.status.
  PlayerStatus _getPlayerCardStatus(Player player) {
    final isOnCourt = _isPlayerOnCourt(player);
    final isQueued = _isPlayerQueued(player);

    if (isOnCourt && isQueued) {
      return PlayerStatus.queuedWhilePlaying;
    }

    if (isOnCourt) {
      return PlayerStatus.inCourt;
    }

    if (isQueued) {
      return PlayerStatus.inQueue;
    }

    return PlayerStatus.idle;
  }

  Future<void> _confirmDeletePlayer(Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete player?'),
        content: Text(
          'Are you sure you want to delete "${player.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    widget.playerController.deletePlayer(player.id);

    _showMessage('${player.name} deleted.');
  }

  Future<void> _confirmDeleteCourt(dynamic court) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete court?'),
        content: Text(
          'Delete "${court.name}" and remove its player assignments?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    widget.courtController.deleteCourt(court.id);

    _showMessage('"${court.name}" deleted.');
  }

  Future<void> _confirmDeleteQueue(QueueGroup queueGroup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete queue?'),
        content: Text(
          'Delete "${queueGroup.name}" and remove all players from it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    widget.queueController.deleteQueue(queueGroup.id);

    _showMessage('"${queueGroup.name}" deleted.');
  }

  void _addPlayerToQueue(
    QueueGroup queueGroup,
    Player player,
    QueueTeam targetTeam,
    int targetSlot,
  ) {
    final currentQueue = queueGroup.queue;

    // Find the player being dragged in the current queue.
    final draggedEntryIndex = currentQueue.entries.indexWhere(
      (entry) => entry.player.id == player.id,
    );

    // Find the player currently occupying the destination slot.
    final targetEntryIndex = currentQueue.entries.indexWhere(
      (entry) => entry.team == targetTeam && entry.slotIndex == targetSlot,
    );

    // ---------------------------------------------------------------
    // CASE 1: PLAYER IS ALREADY IN THIS QUEUE
    // ---------------------------------------------------------------

    if (draggedEntryIndex != -1) {
      final draggedEntry = currentQueue.entries[draggedEntryIndex];

      // Dropped onto their own slot.
      if (draggedEntry.team == targetTeam &&
          draggedEntry.slotIndex == targetSlot) {
        return;
      }

      final updatedEntries = [...currentQueue.entries];

      // Destination is occupied: SWAP positions.
      if (targetEntryIndex != -1) {
        final targetEntry = updatedEntries[targetEntryIndex];

        updatedEntries[draggedEntryIndex] = draggedEntry.copyWith(
          team: targetEntry.team,
          slotIndex: targetEntry.slotIndex,
        );

        updatedEntries[targetEntryIndex] = targetEntry.copyWith(
          team: draggedEntry.team,
          slotIndex: draggedEntry.slotIndex,
        );
      } else {
        // Destination is empty: MOVE to that exact slot.
        updatedEntries[draggedEntryIndex] = draggedEntry.copyWith(
          team: targetTeam,
          slotIndex: targetSlot,
        );
      }

      widget.queueController.updateQueue(
        queueGroup.copyWith(
          queue: currentQueue.copyWith(entries: updatedEntries),
        ),
      );

      return;
    }

    // ---------------------------------------------------------------
    // CASE 2: PLAYER IS NOT IN THIS QUEUE
    // ---------------------------------------------------------------

    final isQueuedElsewhere = widget.queueController.queues.any(
      (group) =>
          group.id != queueGroup.id &&
          group.queue.entries.any((entry) => entry.player.id == player.id),
    );

    if (isQueuedElsewhere) {
      _showMessage('${player.name} is already in another queue.');
      return;
    }

    if (_isPlayerOnCourt(player)) {
      _showMessage('${player.name} is already assigned to a court.');
      return;
    }

    // The destination must be empty for a new player.
    if (targetEntryIndex != -1) {
      _showMessage('That slot is already occupied.');
      return;
    }

    final entry = QueueEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      player: player,
      team: targetTeam,
      slotIndex: targetSlot,
      priority: QueuePriority.normal,
      createdAt: DateTime.now(),
    );

    try {
      final updatedQueue = currentQueue.add(entry);

      widget.queueController.updateQueue(
        queueGroup.copyWith(queue: updatedQueue),
      );
    } on StateError catch (error) {
      _showMessage(error.message.toString());
    }
  }

  void _showEditDialog(Player player) {
    final nameController = TextEditingController(text: player.name);
    SkillLevel selectedSkill = player.skillLevel;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Player'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<SkillLevel>(
                    initialValue: selectedSkill,
                    decoration: const InputDecoration(
                      labelText: 'Skill Level',
                      border: OutlineInputBorder(),
                    ),
                    items: SkillLevel.values.map((level) {
                      return DropdownMenuItem<SkillLevel>(
                        value: level,
                        child: Text(level.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        selectedSkill = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedName = nameController.text.trim();

                    if (updatedName.isEmpty) {
                      return;
                    }

                    widget.playerController.updatePlayer(
                      player.copyWith(
                        name: updatedName,
                        skillLevel: selectedSkill,
                      ),
                    );

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
    });
  }

  void _addPlayer() {
    final nextNumber = widget.playerController.players.length + 1;

    widget.playerController.addPlayer(
      Player(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Player $nextNumber',
        skillLevel: SkillLevel.beginner,
        gamesPlayed: 0,
        wins: 0,
        paymentStatus: PaymentStatus.unpaid,
        status: PlayerStatus.idle,
        availability: PlayerAvailability.present,
      ),
    );
  }

  Widget _buildDraggablePlayer(Player player) {
    final status = _getPlayerCardStatus(player);

    final card = PlayerCard(
      player: player,
      status: status,
      onEdit: () => _showEditDialog(player),
      onDelete: () => _confirmDeletePlayer(player),
      onTogglePayment: () {
        widget.playerController.togglePayment(player.id);
      },
      onToggleAvailability: () {
        widget.playerController.toggleAvailability(player.id);
      },
    );

    return Draggable<Player>(
      data: player,
      maxSimultaneousDrags: 1,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 260, child: Opacity(opacity: 0.9, child: card)),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: card),
    );
  }

  Widget _buildCourtCard(dynamic court) {
    return MatchCard(
      title: court.name,
      actionText: 'Start Game',
      onAction: () {
        _showMessage(
          'The game starts automatically when all four player slots are filled.',
        );
      },
      teams: const [<String>[], <String>[]],
      teamAPlayers: court.teamA,
      teamBPlayers: court.teamB,
      canEditTeams: true,
      onRename: (newName) {
        widget.courtController.updateCourt(court.copyWith(name: newName));

        _showMessage('Court renamed to "$newName".');
      },
      onAssignPlayer: (player, toTeamA) {
        final success = widget.courtController.assignPlayer(
          courtId: court.id,
          player: player,
          toTeamA: toTeamA,
        );

        if (!success) {
          _showMessage(
            'Cannot assign player. Check whether the court or team is full, '
            'or whether the player is already assigned to a court.',
          );
        }

        return success;
      },
      onMovePlayer: (player, fromTeamA, fromSlot, toTeamA, toSlot) {
        return widget.courtController.movePlayer(
          courtId: court.id,
          playerId: player.id,
          fromTeamA: fromTeamA,
          fromSlot: fromSlot,
          toTeamA: toTeamA,
          toSlot: toSlot,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // =========================================================
          // LEFT SIDE: PLAYERS
          // =========================================================
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedBuilder(
                      animation: _playerStateListenable,
                      builder: (context, _) {
                        final players = widget.playerController.players;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Players (${players.length})',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 32,
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value
                                              .trim()
                                              .toLowerCase();
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search player...',
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
                                SizedBox(
                                  height: 32,
                                  child: ElevatedButton.icon(
                                    onPressed: _addPlayer,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Drag players onto a court to assign them.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _playerStateListenable,
                      builder: (context, _) {
                        final players = widget.playerController.players.where((
                          player,
                        ) {
                          return player.name.toLowerCase().contains(
                            _searchQuery,
                          );
                        }).toList();

                        if (players.isEmpty) {
                          return Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'No players yet.\n'
                                        'Click Add to create a player.'
                                  : 'No players match your search.',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width < 1000 ? 4 : 6,
                          ),
                          itemCount: players.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _getCrossAxisCount(context),
                                childAspectRatio: 4.2,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 2,
                              ),
                          itemBuilder: (context, index) {
                            return _buildDraggablePlayer(players[index]);
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

          // =========================================================
          // RIGHT SIDE: COURTS AND QUEUES
          // =========================================================
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // =====================================================
                // COURTS
                // =====================================================
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.sports_tennis, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Courts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            AnimatedBuilder(
                              animation: widget.courtController,
                              builder: (context, _) {
                                return Text(
                                  '${widget.courtController.courts.length}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                widget.courtController.addCourt();
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Court'),
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: widget.courtController,
                            builder: (context, _) {
                              final courts = widget.courtController.courts;

                              if (courts.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No courts added yet.\n'
                                    'Click Add Court to get started.',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              return GridView.builder(
                                padding: const EdgeInsets.all(4),
                                itemCount: courts.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: _getCrossAxisCount(
                                        context,
                                      ),
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: 3,
                                    ),
                                itemBuilder: (context, index) {
                                  final court = courts[index];

                                  return _buildCourtCard(court);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // =====================================================
                // QUEUES
                // =====================================================
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.queue, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Queues',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            AnimatedBuilder(
                              animation: widget.queueController,
                              builder: (context, _) {
                                return Text(
                                  '${widget.queueController.queues.length}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                widget.queueController.addQueue();
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Queue'),
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: widget.queueController,
                            builder: (context, _) {
                              final queues = widget.queueController.queues;

                              if (queues.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No queues added yet.\n'
                                    'Click Add Queue to get started.',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: queues.length,
                                itemBuilder: (context, index) {
                                  final queueGroup = queues[index];

                                  final playerNames = queueGroup.queue.entries
                                      .map((entry) => entry.player.name)
                                      .toList();

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: QueueCard(
                                      title: queueGroup.name,
                                      actionText: 'Transfer to Court',
                                      teamA: List.generate(2, (slot) {
                                        final matchingEntries = queueGroup
                                            .queue
                                            .teamAEntries
                                            .where(
                                              (entry) =>
                                                  entry.slotIndex == slot,
                                            );

                                        return matchingEntries.isEmpty
                                            ? null
                                            : matchingEntries.first.player;
                                      }),

                                      teamB: List.generate(2, (slot) {
                                        final matchingEntries = queueGroup
                                            .queue
                                            .teamBEntries
                                            .where(
                                              (entry) =>
                                                  entry.slotIndex == slot,
                                            );

                                        return matchingEntries.isEmpty
                                            ? null
                                            : matchingEntries.first.player;
                                      }),
                                      onPlayerDropped:
                                          (player, team, slotIndex) {
                                            _addPlayerToQueue(
                                              queueGroup,
                                              player,
                                              team,
                                              slotIndex,
                                            );
                                          },
                                      onRemovePlayer: (player, team) {
                                        final entry = queueGroup.queue.entries
                                            .firstWhere(
                                              (entry) =>
                                                  entry.player.id ==
                                                      player.id &&
                                                  entry.team == team,
                                            );

                                        final updatedQueue = queueGroup.queue
                                            .remove(entry.id);

                                        widget.queueController.updateQueue(
                                          queueGroup.copyWith(
                                            queue: updatedQueue,
                                          ),
                                        );
                                      },
                                      onDelete: () {
                                        // Immediate deletion, with no confirmation dialog.
                                        widget.queueController.deleteQueue(
                                          queueGroup.id,
                                        );
                                      },
                                      onAction: () {
                                        if (queueGroup.queue.entries.length <
                                            2) {
                                          _showMessage(
                                            'At least 2 players are required to transfer to a court.',
                                          );
                                          return;
                                        }

                                        // Keep your existing court-transfer implementation here.
                                        // If transfer is not implemented yet, this button will not transfer
                                        // players until that logic is added.
                                        _showMessage(
                                          'Court transfer logic still needs to be implemented.',
                                        );
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
