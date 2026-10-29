import 'package:flutter/material.dart';

import '../../../domain/models/player.dart';
import '../../../domain/enums/payment_status.dart';
import '../../../domain/enums/player_availability.dart';
import '../../../domain/enums/player_status.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final PlayerStatus status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePayment;
  final VoidCallback onToggleAvailability;

  const PlayerCard({
    super.key,
    required this.player,
    this.status = PlayerStatus.idle,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePayment,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Player>(
      data: player,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 260,
          child: _buildCard(context, isDragging: true),
        ),
      ),
      child: _buildCard(context),
    );
  }

  Color _getStatusColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case PlayerStatus.idle:
        return Theme.of(context).colorScheme.surface;

      case PlayerStatus.inQueue:
        return isDark
            ? Colors.orange.shade900.withValues(alpha: 0.35)
            : Colors.orange.shade50;

      case PlayerStatus.inCourt:
        return isDark
            ? Colors.blue.shade900.withValues(alpha: 0.4)
            : Colors.blue.shade50;

      case PlayerStatus.queuedWhilePlaying:
        return isDark
            ? Colors.purple.shade900.withValues(alpha: 0.4)
            : Colors.purple.shade50;
    }
  }

  Color _getStatusBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case PlayerStatus.idle:
        return Theme.of(context).colorScheme.outline.withValues(alpha: 0.2);

      case PlayerStatus.inQueue:
        return isDark ? Colors.orange.shade700 : Colors.orange.shade300;

      case PlayerStatus.inCourt:
        return isDark ? Colors.blue.shade700 : Colors.blue.shade300;

      case PlayerStatus.queuedWhilePlaying:
        return isDark ? Colors.purple.shade700 : Colors.purple.shade300;
    }
  }

  Color _getStatusTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case PlayerStatus.idle:
        return Theme.of(context).colorScheme.onSurfaceVariant;

      case PlayerStatus.inQueue:
        return isDark ? Colors.orange.shade200 : Colors.orange.shade900;

      case PlayerStatus.inCourt:
        return isDark ? Colors.blue.shade200 : Colors.blue.shade900;

      case PlayerStatus.queuedWhilePlaying:
        return isDark ? Colors.purple.shade200 : Colors.purple.shade900;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case PlayerStatus.idle:
        return 'AVAILABLE';

      case PlayerStatus.inQueue:
        return 'QUEUED';

      case PlayerStatus.inCourt:
        return 'ON COURT';

      case PlayerStatus.queuedWhilePlaying:
        return 'COURT + QUEUED';
    }
  }

  Widget _buildCard(BuildContext context, {bool isDragging = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPaid = player.paymentStatus == PaymentStatus.paid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isDragging
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
            : _getStatusColor(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _getStatusBorderColor(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onToggleAvailability,
                        child: Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: switch (player.availability) {
                              PlayerAvailability.present => Colors.green,
                              PlayerAvailability.absent => Colors.red,
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${player.name} (${player.skillLevel})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit player',
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit),
                color: colorScheme.primary,
                onPressed: onEdit,
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Delete player',
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete),
                color: colorScheme.error,
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Games: ${player.gamesPlayed} | Wins: ${player.wins}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _getStatusTextColor(context).withValues(alpha: 0.12),
                ),
                child: Text(
                  _getStatusLabel(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: _getStatusTextColor(context),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onTogglePayment,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isPaid
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                    ),
                    child: Text(
                      isPaid ? 'PAID' : 'UNPAID',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPaid ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
