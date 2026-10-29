import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/queue_entry.dart';

import '../../domain/models/player.dart';
import '../../domain/models/court.dart';
import '../../domain/models/queue.dart';
import '../../domain/models/queue_entry.dart';
import '../../domain/models/queue_group.dart';

import '../../domain/enums/payment_status.dart';
import '../../domain/enums/player_status.dart';
import '../../domain/enums/player_availability.dart';
import '../../domain/enums/skill_level.dart';
import '../../domain/enums/court_status.dart';
import '../../domain/enums/queue_priority.dart';
import '../../domain/enums/queue_team.dart';

class LocalStorageService {
  LocalStorageService._();

  static const String _playersKey = 'players';
  static const String _courtsKey = 'courts';
  static const String _queuesKey = 'queues';
  static const String _themeKey = 'themeMode';

  // --------------------------------------------------
  // PLAYERS
  // --------------------------------------------------

  static Future<void> savePlayers(List<Player> players) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _playersKey,
      jsonEncode(players.map(_playerToJson).toList()),
    );
  }

  static Future<List<Player>> loadPlayers() async {
    final preferences = await SharedPreferences.getInstance();
    final savedData = preferences.getString(_playersKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    return _decodeList(savedData, (json) => _playerFromJson(json), 'players');
  }

  // --------------------------------------------------
  // COURTS
  // --------------------------------------------------

  static Future<void> saveCourts(List<Court> courts) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _courtsKey,
      jsonEncode(courts.map(_courtToJson).toList()),
    );
  }

  static Future<List<Court>> loadCourts() async {
    final preferences = await SharedPreferences.getInstance();
    final savedData = preferences.getString(_courtsKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    return _decodeList(savedData, (json) => _courtFromJson(json), 'courts');
  }

  // --------------------------------------------------
  // QUEUES
  // --------------------------------------------------

  static Future<void> saveQueues(List<QueueGroup> queues) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _queuesKey,
      jsonEncode(queues.map(_queueGroupToJson).toList()),
    );
  }

  static Future<List<QueueGroup>> loadQueues() async {
    final preferences = await SharedPreferences.getInstance();
    final savedData = preferences.getString(_queuesKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    return _decodeList(
      savedData,
      (json) => _queueGroupFromJson(json),
      'queues',
    );
  }

  // --------------------------------------------------
  // THEME
  // --------------------------------------------------

  static Future<void> saveTheme(String themeMode) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_themeKey, themeMode);
  }

  static Future<String> loadTheme() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_themeKey) ?? 'light';
  }

  // --------------------------------------------------
  // JSON DECODING
  // --------------------------------------------------

  static List<T> _decodeList<T>(
    String savedData,
    T Function(Map<String, dynamic>) fromJson,
    String dataType,
  ) {
    try {
      final decoded = jsonDecode(savedData) as List<dynamic>;

      return decoded.map((item) {
        return fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();
    } catch (error) {
      throw FormatException(
        'Unable to restore saved $dataType. '
        'The original saved data has not been overwritten.',
        error,
      );
    }
  }

  // --------------------------------------------------
  // PLAYER SERIALIZATION
  // --------------------------------------------------

  static Map<String, dynamic> _playerToJson(Player player) {
    return {
      'id': player.id,
      'name': player.name,
      'skillLevel': player.skillLevel.name,
      'gamesPlayed': player.gamesPlayed,
      'wins': player.wins,
      'paymentStatus': player.paymentStatus.name,
      'status': player.status.name,
      'availability': player.availability.name,
    };
  }

  static Player _playerFromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      skillLevel: SkillLevel.values.byName(json['skillLevel'] as String),
      gamesPlayed: json['gamesPlayed'] as int,
      wins: json['wins'] as int,
      paymentStatus: PaymentStatus.values.byName(
        json['paymentStatus'] as String,
      ),
      status: PlayerStatus.values.byName(json['status'] as String),
      availability: PlayerAvailability.values.byName(
        json['availability'] as String,
      ),
    );
  }

  // --------------------------------------------------
  // COURT SERIALIZATION
  // --------------------------------------------------

  static Map<String, dynamic> _courtToJson(Court court) {
    return {
      'id': court.id,
      'name': court.name,
      'status': court.status.name,
      'teamA': court.teamA.map(_playerToJson).toList(),
      'teamB': court.teamB.map(_playerToJson).toList(),
      'startedAt': court.startedAt?.toIso8601String(),
    };
  }

  static Court _courtFromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] as String,
      name: json['name'] as String,
      status: CourtStatus.values.byName(json['status'] as String),
      teamA: (json['teamA'] as List<dynamic>)
          .map(
            (player) =>
                _playerFromJson(Map<String, dynamic>.from(player as Map)),
          )
          .toList(),
      teamB: (json['teamB'] as List<dynamic>)
          .map(
            (player) =>
                _playerFromJson(Map<String, dynamic>.from(player as Map)),
          )
          .toList(),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
    );
  }

  // --------------------------------------------------
  // QUEUE SERIALIZATION
  // --------------------------------------------------

  static Map<String, dynamic> _queueGroupToJson(QueueGroup group) {
    return {
      'id': group.id,
      'name': group.name,
      'entries': group.queue.entries.map(_queueEntryToJson).toList(),
    };
  }

  static QueueGroup _queueGroupFromJson(Map<String, dynamic> json) {
    final entries = (json['entries'] as List<dynamic>)
        .map(
          (entry) =>
              _queueEntryFromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList();

    return QueueGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      queue: Queue(entries: entries),
    );
  }

  static Map<String, dynamic> _queueEntryToJson(QueueEntry entry) {
    return {
      'id': entry.id,
      'player': _playerToJson(entry.player),
      'priority': entry.priority.name,
      'createdAt': entry.createdAt.toIso8601String(),
    };
  }

  static QueueEntry _queueEntryFromJson(Map<String, dynamic> json) {
    return QueueEntry(
      id: json['id'] as String,
      player: _playerFromJson(Map<String, dynamic>.from(json['player'] as Map)),
      priority: QueuePriority.values.byName(json['priority'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      team: QueueTeam.values.firstWhere(
        (team) => team.name == json['team'],
        orElse: () => QueueTeam.teamA,
      ),
    );
  }
}
