import 'package:flutter/material.dart';

import '../../domain/enums/queue_team.dart';
import '../../domain/models/player.dart';

class QueueCard extends StatelessWidget {
  final String title;
  final String actionText;
  final List<Player?> teamA;
  final List<Player?> teamB;

  final Function(Player, QueueTeam, int) onPlayerDropped;
  final Function(Player, QueueTeam)? onRemovePlayer;
  final VoidCallback onDelete;
  final VoidCallback onAction;
  final ValueChanged<String>? onRename;

  const QueueCard({
    super.key,
    required this.title,
    required this.actionText,
    required this.teamA,
    required this.teamB,
    required this.onPlayerDropped,
    required this.onDelete,
    required this.onAction,
    this.onRemovePlayer,
    this.onRename,
  });

  int get totalPlayers =>
      teamA.whereType<Player>().length + teamB.whereType<Player>().length;

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _teamBackground(BuildContext context) {
    return _isDark(context)
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Colors.grey.shade100;
  }

  Color _emptySlotBackground(BuildContext context) {
    return _isDark(context)
        ? Theme.of(context).colorScheme.surface
        : Colors.white;
  }

  Color _filledSlotBackground(BuildContext context) {
    return _isDark(context)
        ? Colors.blue.shade900.withValues(alpha: 0.35)
        : Colors.blue.shade50;
  }

  Color _slotBorderColor(BuildContext context, {required bool filled}) {
    if (filled) {
      return _isDark(context) ? Colors.blue.shade700 : Colors.blue.shade200;
    }

    return _isDark(context) ? Colors.grey.shade700 : Colors.grey.shade300;
  }

  Color _mutedTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                const Icon(Icons.queue, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
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
                      const SizedBox(width: 2),
                      IconButton(
                        tooltip: 'Delete queue',
                        icon: const Icon(Icons.delete_outline),
                        iconSize: 16,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        color: theme.colorScheme.error,
                        onPressed: onDelete,
                      ),
                      if (onRename != null)
                        IconButton(
                          tooltip: 'Rename queue',
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
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$totalPlayers/4 players',
                  style: TextStyle(
                    fontSize: 11,
                    color: _mutedTextColor(context),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: totalPlayers >= 2 ? onAction : null,
                  icon: const Icon(Icons.sports_tennis, size: 15),
                  label: Text(actionText, style: const TextStyle(fontSize: 11)),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTeam(
                    context: context,
                    label: 'Team A',
                    team: QueueTeam.teamA,
                    players: teamA,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildTeam(
                    context: context,
                    label: 'Team B',
                    team: QueueTeam.teamB,
                    players: teamB,
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
  // RENAME QUEUE
  // ---------------------------------------------------------------

  Future<void> _showRenameDialog(BuildContext context) async {
    final controller = TextEditingController(text: title);

    try {
      final newName = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Rename Queue'),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLength: 40,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Queue name',
                hintText: 'e.g. Queue 1',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              onSubmitted: (value) {
                final name = value.trim();
                if (name.isNotEmpty) {
                  Navigator.of(dialogContext).pop(name);
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
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    Navigator.of(dialogContext).pop(name);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (newName != null && newName.trim().isNotEmpty) {
        final name = newName.trim();
        if (name != title) {
          onRename?.call(name);
        }
      }
    } finally {
      controller.dispose();
    }
  }

  // ---------------------------------------------------------------
  // TEAM CONTAINER
  // ---------------------------------------------------------------

  Widget _buildTeam({
    required BuildContext context,
    required String label,
    required QueueTeam team,
    required List<Player?> players,
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
              team: team,
              slotIndex: slot,
              player: players[slot],
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // DRAG-AND-DROP PLAYER SLOT
  // ---------------------------------------------------------------

  Widget _buildPlayerSlot({
    required BuildContext context,
    required QueueTeam team,
    required int slotIndex,
    required Player? player,
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
          if (player != null && onRemovePlayer != null)
            SizedBox(
              width: 22,
              height: 24,
              child: IconButton(
                tooltip: 'Remove player',
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                iconSize: 14,
                onPressed: () => onRemovePlayer!(player, team),
                icon: const Icon(Icons.close),
              ),
            ),
        ],
      ),
    );

    final Widget draggableSlot;

    if (player != null) {
      draggableSlot = Draggable<Player>(
        data: player,
        maxSimultaneousDrags: 1,
        feedback: Material(
          color: Colors.transparent,
          elevation: 4,
          child: SizedBox(width: 150, child: slotContent),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: slotContent),
        child: MouseRegion(cursor: SystemMouseCursors.grab, child: slotContent),
      );
    } else {
      draggableSlot = slotContent;
    }

    return DragTarget<Player>(
      onWillAcceptWithDetails: (details) {
        // Reject dropping a player onto their own slot.
        return player?.id != details.data.id;
      },
      onAcceptWithDetails: (details) {
        onPlayerDropped(details.data, team, slotIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        if (!isHovering) {
          return draggableSlot;
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: draggableSlot,
        );
      },
    );
  }
}
