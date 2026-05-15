import 'player.dart';
import 'package:queuing_system/domain/enums/queue_priority.dart';

class QueueEntry {
  final String id;
  final Player player;
  final QueuePriority priority;
  final DateTime createdAt;

  QueueEntry({
    required this.id,
    required this.player,
    required this.priority,
    required this.createdAt,
  });

  QueueEntry copyWith({
    String? id,
    Player? player,
    QueuePriority? priority,
    DateTime? createdAt,
  }) {
    return QueueEntry(
      id: id ?? this.id,
      player: player ?? this.player,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
