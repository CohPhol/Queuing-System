import 'package:flutter/material.dart';

import '../../domain/models/court.dart';
import '../../domain/models/player.dart';
import '../../domain/enums/court_status.dart';
import '../services/local_storage_service.dart';

class CourtController extends ChangeNotifier {
  final List<Court> _courts = [];

  List<Court> get courts => List.unmodifiable(_courts);

  int get courtCount => _courts.length;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final savedCourts = await LocalStorageService.loadCourts();

    _courts
      ..clear()
      ..addAll(
        savedCourts.map(
          (court) => court.copyWith(
            teamA: _normalizeSlots(court.teamA),
            teamB: _normalizeSlots(court.teamB),
          ),
        ),
      );

    _initialized = true;
    notifyListeners();
  }

  // Ensure every team always has exactly two slots.
  List<Player?> _normalizeSlots(List<Player?> players) {
    return [for (var i = 0; i < 2; i++) i < players.length ? players[i] : null];
  }

  Future<void> _save() async {
    if (!_initialized) return;
    await LocalStorageService.saveCourts(_courts);
  }

  // CREATE
  void addCourt() {
    _courts.add(
      Court(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Court ${_nextCourtNumber()}',
        status: CourtStatus.empty,
        teamA: [null, null],
        teamB: [null, null],
      ),
    );

    notifyListeners();
    _save();
  }

  // DELETE
  void deleteCourt(String id) {
    final originalLength = _courts.length;

    _courts.removeWhere((court) => court.id == id);

    if (_courts.length == originalLength) return;

    notifyListeners();
    _save();
  }

  // UPDATE
  void updateCourt(Court updatedCourt) {
    final index = _courts.indexWhere((court) => court.id == updatedCourt.id);

    if (index == -1) return;

    final normalizedCourt = updatedCourt.copyWith(
      teamA: _normalizeSlots(updatedCourt.teamA),
      teamB: _normalizeSlots(updatedCourt.teamB),
    );

    _courts[index] = _withAutoStart(normalizedCourt);

    notifyListeners();
    _save();
  }

  // ASSIGN PLAYER
  bool assignPlayer({
    required String courtId,
    required Player player,
    required bool toTeamA,
    required int toSlot,
  }) {
    final courtIndex = _courts.indexWhere((court) => court.id == courtId);

    if (courtIndex == -1) return false;

    final court = _courts[courtIndex];

    // Do not assign new players after the game starts.
    if (court.status == CourtStatus.inProgress) return false;

    if (toSlot < 0 || toSlot > 1) return false;

    // Prevent assignment to multiple courts.
    final assignedToAnotherCourt = _courts.any((existingCourt) {
      if (existingCourt.id == courtId) return false;

      return [...existingCourt.teamA, ...existingCourt.teamB]
          .whereType<Player>()
          .any((existingPlayer) => existingPlayer.id == player.id);
    });

    if (assignedToAnotherCourt) return false;

    // Prevent duplicate assignments on the same court.
    final alreadyOnThisCourt = [...court.teamA, ...court.teamB]
        .whereType<Player>()
        .any((existingPlayer) => existingPlayer.id == player.id);

    if (alreadyOnThisCourt) return false;

    final teamA = List<Player?>.from(court.teamA);
    final teamB = List<Player?>.from(court.teamB);

    final targetTeam = toTeamA ? teamA : teamB;

    // The exact destination slot must be empty.
    if (targetTeam[toSlot] != null) return false;

    targetTeam[toSlot] = player;

    _courts[courtIndex] = _withAutoStart(
      court.copyWith(teamA: teamA, teamB: teamB),
    );

    notifyListeners();
    _save();

    return true;
  }

  // MOVE OR SWAP PLAYER BETWEEN COURT SLOTS
  bool movePlayer({
    required String courtId,
    required String playerId,
    required bool fromTeamA,
    required int fromSlot,
    required bool toTeamA,
    required int toSlot,
  }) {
    final courtIndex = _courts.indexWhere((court) => court.id == courtId);

    if (courtIndex == -1) return false;

    final court = _courts[courtIndex];

    if (fromSlot < 0 || fromSlot > 1) return false;
    if (toSlot < 0 || toSlot > 1) return false;

    if (fromTeamA == toTeamA && fromSlot == toSlot) {
      return false;
    }

    final teamA = List<Player?>.from(court.teamA);
    final teamB = List<Player?>.from(court.teamB);

    final sourceTeam = fromTeamA ? teamA : teamB;
    final destinationTeam = toTeamA ? teamA : teamB;

    final sourcePlayer = sourceTeam[fromSlot];

    if (sourcePlayer == null || sourcePlayer.id != playerId) {
      return false;
    }

    final destinationPlayer = destinationTeam[toSlot];

    // If destination is occupied, swap the two players.
    if (destinationPlayer != null) {
      sourceTeam[fromSlot] = destinationPlayer;
      destinationTeam[toSlot] = sourcePlayer;
    } else {
      // If destination is empty, move the player and leave
      // the original slot empty.
      sourceTeam[fromSlot] = null;
      destinationTeam[toSlot] = sourcePlayer;
    }

    _courts[courtIndex] = _withAutoStart(
      court.copyWith(teamA: teamA, teamB: teamB),
    );

    notifyListeners();
    _save();

    return true;
  }

  // REMOVE PLAYER
  bool removePlayer({required String courtId, required String playerId}) {
    final courtIndex = _courts.indexWhere((court) => court.id == courtId);

    if (courtIndex == -1) return false;

    final court = _courts[courtIndex];

    if (court.status == CourtStatus.inProgress) return false;

    final teamA = List<Player?>.from(court.teamA);
    final teamB = List<Player?>.from(court.teamB);

    var removed = false;

    for (var i = 0; i < 2; i++) {
      if (teamA[i]?.id == playerId) {
        teamA[i] = null;
        removed = true;
      }

      if (teamB[i]?.id == playerId) {
        teamB[i] = null;
        removed = true;
      }
    }

    if (!removed) return false;

    _courts[courtIndex] = court.copyWith(
      teamA: teamA,
      teamB: teamB,
      status: CourtStatus.empty,
      startedAt: null,
    );

    notifyListeners();
    _save();

    return true;
  }

  // AUTOMATICALLY START WHEN FOUR PLAYERS ARE ASSIGNED
  Court _withAutoStart(Court court) {
    final isFull =
        court.teamA.whereType<Player>().length == 2 &&
        court.teamB.whereType<Player>().length == 2;

    if (isFull && court.status != CourtStatus.inProgress) {
      return court.copyWith(
        status: CourtStatus.inProgress,
        startedAt: DateTime.now(),
      );
    }

    return court;
  }

  // FIND THE SMALLEST AVAILABLE COURT NUMBER
  int _nextCourtNumber() {
    final existingNumbers = _courts
        .map((court) {
          final match = RegExp(r'^Court (\d+)$').firstMatch(court.name);
          return int.tryParse(match?.group(1) ?? '');
        })
        .whereType<int>()
        .toSet();

    var number = 1;

    while (existingNumbers.contains(number)) {
      number++;
    }

    return number;
  }
}
