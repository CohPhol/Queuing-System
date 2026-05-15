import 'player.dart';
import 'package:queuing_system/domain/enums/court_status.dart';

class Court {
  final String id;
  final String name;
  final CourtStatus status;

  final List<Player> teamA; // always 2 players
  final List<Player> teamB; // always 2 players

  final DateTime? startedAt;

  Court({
    required this.id,
    required this.name,
    required this.status,
    required this.teamA,
    required this.teamB,
    this.startedAt,
  });

  Court copyWith({
    String? id,
    String? name,
    CourtStatus? status,
    List<Player>? teamA,
    List<Player>? teamB,
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
