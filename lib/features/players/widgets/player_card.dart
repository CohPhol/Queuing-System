import 'package:flutter/material.dart';
import '../../../domain/models/player.dart';
import '../../../domain/enums/skill_level.dart';
import '../../../domain/enums/payment_status.dart';
import '../../../domain/enums/player_availability.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePayment;
  final VoidCallback onToggleAvailability;

  const PlayerCard({
    super.key,
    required this.player,
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
        child: _buildCard(context, isDragging: true),
      ),
      child: _buildCard(context),
    );
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
            ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outline.withOpacity(0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ================= TOP ROW =================
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // ================= AVAILABILITY DOT =================
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

                    // ================= NAME =================
                    Expanded(
                      child: Text(
                        "${player.name} (${player.skillLevel.label})",
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
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit),
                color: colorScheme.primary,
                onPressed: onEdit,
              ),

              IconButton(
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

          // ================= BOTTOM ROW =================
          Row(
            children: [
              Expanded(
                child: Text(
                  "Games:${player.gamesPlayed} | Wins:${player.wins}",
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),

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
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                    ),
                    child: Text(
                      isPaid ? "PAID" : "UNPAID",
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
