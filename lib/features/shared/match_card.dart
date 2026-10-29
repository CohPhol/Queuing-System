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
  final VoidCallback? onDelete;

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
    this.onDelete,
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
  // THEME HELPERS
  // ---------------------------------------------------------------

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _teamBackground(BuildContext context) {
    final isDark = _isDark(context);
    return isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Colors.grey.shade100;
  }

  Color _emptySlotBackground(BuildContext context) {
    final isDark = _isDark(context);
    return isDark ? Theme.of(context).colorScheme.surface : Colors.white;
  }

  Color _filledSlotBackground(BuildContext context) {
    final isDark = _isDark(context);
    return isDark
        ? Colors.blue.shade900.withValues(alpha: 0.35)
        : Colors.blue.shade50;
  }

  Color _slotBorderColor(BuildContext context, {required bool filled}) {
    final isDark = _isDark(context);

    if (filled) {
      return isDark ? Colors.blue.shade700 : Colors.blue.shade200;
    }

    return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
  }

  Color _mutedTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

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
                Expanded(child: _buildNameTeam(context, 'Team A', teamA)),
                const SizedBox(width: 8),
                Expanded(child: _buildNameTeam(context, 'Team B', teamB)),
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
  // ---------------------------------------------------------------

  Widget _buildCourtCard(BuildContext context) {
    final allSlotsFilled = teamAPlayers!.length + teamBPlayers!.length == 4;

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
                if (onDelete != null)
                  IconButton(
                    tooltip: 'Delete court',
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 16,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: onDelete,
                  ),
                if (allSlotsFilled)
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
                    context: context,
                    label: 'Team A',
                    players: teamAPlayers!,
                    isTeamA: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildPlayerTeam(
                    context: context,
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

  // ---------------------------------------------------------------
  // QUEUE TEAM
  // ---------------------------------------------------------------

  Widget _buildNameTeam(
    BuildContext context,
    String label,
    List<String> players,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _teamBackground(context),
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
              style: TextStyle(color: _mutedTextColor(context), fontSize: 12),
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

  // ---------------------------------------------------------------
  // COURT TEAM
  // ---------------------------------------------------------------

  Widget _buildPlayerTeam({
    required BuildContext context,
    required String label,
    required List<Player> players,
    required bool isTeamA,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _teamBackground(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor),
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
              context: context,
              player: slot < players.length ? players[slot] : null,
              isTeamA: isTeamA,
              slot: slot,
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // PLAYER SLOT
  // ---------------------------------------------------------------

  Widget _buildPlayerSlot({
    required BuildContext context,
    required Player? player,
    required bool isTeamA,
    required int slot,
  }) {
    final slotContent = Container(
      constraints: const BoxConstraints(minHeight: 36),
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        color: player == null
            ? _emptySlotBackground(context)
            : _filledSlotBackground(context),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: _slotBorderColor(context, filled: player != null),
        ),
      ),
      child: Row(
        children: [
          Icon(
            player == null ? Icons.add : Icons.drag_indicator,
            size: 15,
            color: _mutedTextColor(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              player?.name ?? 'Drop here',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: player == null
                    ? _mutedTextColor(context)
                    : Theme.of(context).colorScheme.onSurface,
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
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: displayedSlot,
        );
      },
    );
  }
}
