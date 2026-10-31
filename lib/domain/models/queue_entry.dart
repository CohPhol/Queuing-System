import 'player.dart';
import 'package:queuing_system/domain/enums/queue_priority.dart';
import 'package:queuing_system/domain/enums/queue_team.dart';

class QueueEntry {
  final String id;
  final Player player;
  final QueuePriority priority;
  final DateTime createdAt;
  final QueueTeam team;
  final int slotIndex;

  QueueEntry({
    required this.id,
    required this.player,
    required this.priority,
    required this.createdAt,
    required this.team,
    this.slotIndex = 0,
  });

  QueueEntry copyWith({
    String? id,
    Player? player,
    QueuePriority? priority,
    DateTime? createdAt,
    QueueTeam? team,
    int? slotIndex,
  }) {
    return QueueEntry(
      id: id ?? this.id,
      player: player ?? this.player,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      team: team ?? this.team,
      slotIndex: slotIndex ?? this.slotIndex,
    );
  }
}
