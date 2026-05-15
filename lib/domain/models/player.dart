import 'package:queuing_system/domain/enums/payment_status.dart';
import 'package:queuing_system/domain/enums/player_status.dart';
import 'package:queuing_system/domain/enums/skill_level.dart';

class Player {
  final String id;
  final String name;
  final SkillLevel skillLevel;
  final int gamesPlayed;
  final int wins;
  final PaymentStatus paymentStatus;
  final PlayerStatus status;

  Player({
    required this.id,
    required this.name,
    required this.skillLevel,
    required this.gamesPlayed,
    required this.wins,
    required this.paymentStatus,
    required this.status,
  });

  Player copyWith({
    String? id,
    String? name,
    SkillLevel? skillLevel,
    int? gamesPlayed,
    int? wins,
    PaymentStatus? paymentStatus,
    PlayerStatus? status,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      skillLevel: skillLevel ?? this.skillLevel,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
    );
  }
}
