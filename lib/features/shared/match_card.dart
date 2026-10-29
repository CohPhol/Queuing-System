import 'package:flutter/material.dart';

import '../../domain/models/player.dart';

class MatchCard extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  // Queue-card support.
  final List<List<String>> teams;

  // Court-card support.
  final List<Player>? teamAPlayers;
  final List<Player>? teamBPlayers;
  final bool canEditTeams;

  // Court renaming support.
  final ValueChanged<String>? onRename;

  final bool Function(
    Player player,
    bool fromTeamA,
    int fromSlot,
    bool toTeamA,
    int toSlot,
  )?
  onMovePlayer;

  final bool Function(Player player, bool toTeamA)? onAssignPlayer;

  const MatchCard({
    super.key,
    required this.title,
    required this.actionText,
    required this.onAction,
    required this.teams,
    this.teamAPlayers,
    this.teamBPlayers,
    this.canEditTeams = false,
    this.onRename,
    this.onMovePlayer,
    this.onAssignPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final isCourtCard = teamAPlayers != null && teamBPlayers != null;

    if (!isCourtCard) {
      return _buildQueueCard(context);
    }

    return _buildCourtCard(context);
  }

  // ---------------------------------------------------------------
  // RENAME COURT
  // ---------------------------------------------------------------
  Future<void> _showRenameDialog(BuildContext context) async {
    final controller = TextEditingController(text: title);

    try {
      final newName = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Rename Court'),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLength: 40,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Court name',
                hintText: 'e.g. Main Court',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              onSubmitted: (value) {
                final trimmedName = value.trim();

                if (trimmedName.isNotEmpty) {
                  Navigator.of(dialogContext).pop(trimmedName);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final trimmedName = controller.text.trim();

                  if (trimmedName.isNotEmpty) {
                    Navigator.of(dialogContext).pop(trimmedName);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (newName != null && newName.trim().isNotEmpty) {
        final trimmedName = newName.trim();

        if (trimmedName != title) {
          onRename?.call(trimmedName);
        }
      }
    } finally {
      controller.dispose();
    }
  }

  // ---------------------------------------------------------------
  // QUEUE CARD
  // Keeps the existing action button.
  // ---------------------------------------------------------------
  Widget _buildQueueCard(BuildContext context) {
    final teamA = teams.isNotEmpty ? teams[0] : <String>[];
    final teamB = teams.length > 1 ? teams[1] : <String>[];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildNameTeam('Team A', teamA)),
                const SizedBox(width: 8),
                Expanded(child: _buildNameTeam('Team B', teamB)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                child: Text(actionText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // COURT CARD
  // Compact layout without a Start Game / End Game button.
  // ---------------------------------------------------------------
  Widget _buildCourtCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.sports_tennis, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // EDIT COURT NAME
                if (onRename != null)
                  IconButton(
                    tooltip: 'Rename court',
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 16,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    onPressed: () => _showRenameDialog(context),
                  ),

                if (teamAPlayers!.length + teamBPlayers!.length == 4)
                  const Tooltip(
                    message: 'All four player slots are filled',
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
            const Divider(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPlayerTeam(
                    label: 'Team A',
                    players: teamAPlayers!,
                    isTeamA: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildPlayerTeam(
                    label: 'Team B',
                    players: teamBPlayers!,
                    isTeamA: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameTeam(String label, List<String> players) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (players.isEmpty)
            Text(
              'No players assigned',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            )
          else
            ...players.map(
              (name) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerTeam({
    required String label,
    required List<Player> players,
    required bool isTeamA,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 6),
          for (var slot = 0; slot < 2; slot++)
            _buildPlayerSlot(
              player: slot < players.length ? players[slot] : null,
              isTeamA: isTeamA,
              slot: slot,
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerSlot({
    required Player? player,
    required bool isTeamA,
    required int slot,
  }) {
    final slotContent = Container(
      constraints: const BoxConstraints(minHeight: 36),
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        color: player == null ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: player == null ? Colors.grey.shade300 : Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            player == null ? Icons.add : Icons.drag_indicator,
            size: 15,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              player?.name ?? 'Drop here',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: player == null ? Colors.grey.shade600 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );

    final canDrag = canEditTeams && player != null && onMovePlayer != null;

    final displayedSlot = canDrag
        ? Draggable<Player>(
            data: player!,
            maxSimultaneousDrags: 1,
            feedback: Material(
              color: Colors.transparent,
              elevation: 4,
              child: SizedBox(width: 150, child: slotContent),
            ),
            childWhenDragging: Opacity(opacity: 0.35, child: slotContent),
            child: slotContent,
          )
        : slotContent;

    return DragTarget<Player>(
      onWillAcceptWithDetails: (details) {
        if (!canEditTeams) return false;

        final draggedPlayer = details.data;
        final existingPlayers = [...?teamAPlayers, ...?teamBPlayers];

        // Allow players already on this court to move between slots.
        if (onMovePlayer != null &&
            existingPlayers.any((p) => p.id == draggedPlayer.id)) {
          return true;
        }

        // Allow players from the player list to enter this court.
        return onAssignPlayer != null;
      },
      onAcceptWithDetails: (details) {
        final draggedPlayer = details.data;
        final existingPlayers = [...?teamAPlayers, ...?teamBPlayers];

        final isAlreadyInThisCourt = existingPlayers.any(
          (p) => p.id == draggedPlayer.id,
        );

        if (isAlreadyInThisCourt) {
          final sourceTeamA = teamAPlayers!.indexWhere(
            (p) => p.id == draggedPlayer.id,
          );

          final sourceTeamB = teamBPlayers!.indexWhere(
            (p) => p.id == draggedPlayer.id,
          );

          if (sourceTeamA != -1) {
            onMovePlayer?.call(draggedPlayer, true, sourceTeamA, isTeamA, slot);
          } else if (sourceTeamB != -1) {
            onMovePlayer?.call(
              draggedPlayer,
              false,
              sourceTeamB,
              isTeamA,
              slot,
            );
          }
        } else {
          onAssignPlayer?.call(draggedPlayer, isTeamA);
        }
      },
      builder: (context, candidateData, rejectedData) {
        if (candidateData.isEmpty) {
          return displayedSlot;
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: displayedSlot,
        );
      },
    );
  }
}
