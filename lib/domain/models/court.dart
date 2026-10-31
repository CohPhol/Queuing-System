import 'player.dart';
import 'package:queuing_system/domain/enums/court_status.dart';

class Court {
  final String id;
  final String name;
  final CourtStatus status;

  // Each team always has exactly two slots.
  // A null value represents an empty slot.
  final List<Player?> teamA;
  final List<Player?> teamB;

  final DateTime? startedAt;

  Court({
    required this.id,
    required this.name,
    required this.status,
    required this.teamA,
    required this.teamB,
    this.startedAt,
  });

  int get totalPlayers =>
      teamA.whereType<Player>().length + teamB.whereType<Player>().length;

  bool get isFull => totalPlayers == 4;

  Court copyWith({
    String? id,
    String? name,
    CourtStatus? status,
    List<Player?>? teamA,
    List<Player?>? teamB,
    DateTime? startedAt,
  }) {
    return Court(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
