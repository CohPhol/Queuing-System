import 'package:flutter/material.dart';

import '../../domain/models/court.dart';
import '../../domain/models/player.dart';
import '../../domain/enums/court_status.dart';

class CourtController extends ChangeNotifier {
  final List<Court> _courts = [];

  List<Court> get courts => List.unmodifiable(_courts);

  int get courtCount => _courts.length;

  void addCourt() {
    _courts.add(
      Court(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Court ${_nextCourtNumber()}',
        status: CourtStatus.empty,
        teamA: [],
        teamB: [],
      ),
    );

    notifyListeners();
  }

  void deleteCourt(String id) {
    _courts.removeWhere((court) => court.id == id);
    notifyListeners();
  }

  void updateCourt(Court updatedCourt) {
    final index = _courts.indexWhere((court) => court.id == updatedCourt.id);

    if (index == -1) return;

    _courts[index] = _withAutoStart(updatedCourt);
    notifyListeners();
  }

  bool assignPlayer({
    required String courtId,
    required Player player,
    required bool toTeamA,
  }) {
    final courtIndex = _courts.indexWhere((court) => court.id == courtId);

    if (courtIndex == -1) return false;

    final court = _courts[courtIndex];

    // Do not assign new players after the game starts.
    if (court.status == CourtStatus.inProgress) return false;

    // Prevent a player from being assigned to more than one court.
    final assignedToAnotherCourt = _courts.any((existingCourt) {
      if (existingCourt.id == courtId) return false;

      return [
        ...existingCourt.teamA,
        ...existingCourt.teamB,
      ].any((existingPlayer) => existingPlayer.id == player.id);
    });

    if (assignedToAnotherCourt) return false;

    // Prevent duplicate assignments on the same court.
    if ([
      ...court.teamA,
      ...court.teamB,
    ].any((existingPlayer) => existingPlayer.id == player.id)) {
      return false;
    }

    final teamA = List<Player>.from(court.teamA);
    final teamB = List<Player>.from(court.teamB);
    final targetTeam = toTeamA ? teamA : teamB;

    if (targetTeam.length >= 2) return false;

    targetTeam.add(player);

    _courts[courtIndex] = _withAutoStart(
      court.copyWith(teamA: teamA, teamB: teamB),
    );

    notifyListeners();
    return true;
  }

  /// Moves a player between court slots.
  ///
  /// Occupied destination: swaps the two players.
  /// Empty destination: moves the player to the empty slot.
  ///
  /// Players can be rearranged after the court automatically starts.
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

    if (fromTeamA == toTeamA && fromSlot == toSlot) {
      return false;
    }

    // Always create separate mutable lists before modifying either team.
    final teamA = List<Player>.from(court.teamA);
    final teamB = List<Player>.from(court.teamB);

    final sourceTeam = fromTeamA ? teamA : teamB;
    final destinationTeam = toTeamA ? teamA : teamB;

    // Validate the source slot.
    if (fromSlot < 0 || fromSlot >= sourceTeam.length) {
      return false;
    }

    // Slots displayed by MatchCard are always 0 and 1.
    if (toSlot < 0 || toSlot > 1) {
      return false;
    }

    final sourcePlayer = sourceTeam[fromSlot];

    // Ensure the dragged player still occupies the expected source slot.
    if (sourcePlayer.id != playerId) {
      return false;
    }

    final destinationIsOccupied = toSlot < destinationTeam.length;

    if (destinationIsOccupied) {
      // Swap by directly assigning the two positions.
      // This is safe even when both teams are the same list.
      final destinationPlayer = destinationTeam[toSlot];

      sourceTeam[fromSlot] = destinationPlayer;
      destinationTeam[toSlot] = sourcePlayer;
    } else {
      // The destination slot is empty.
      sourceTeam.removeAt(fromSlot);

      // Re-evaluate the destination length after removing the source.
      // This matters when moving within the same team.
      if (toSlot > destinationTeam.length) {
        return false;
      }

      destinationTeam.insert(toSlot, sourcePlayer);
    }

    _courts[courtIndex] = _withAutoStart(
      court.copyWith(teamA: teamA, teamB: teamB),
    );

    notifyListeners();
    return true;
  }

  bool removePlayer({required String courtId, required String playerId}) {
    final courtIndex = _courts.indexWhere((court) => court.id == courtId);

    if (courtIndex == -1) return false;

    final court = _courts[courtIndex];

    if (court.status == CourtStatus.inProgress) return false;

    final teamA = court.teamA.where((player) => player.id != playerId).toList();

    final teamB = court.teamB.where((player) => player.id != playerId).toList();

    if (teamA.length == court.teamA.length &&
        teamB.length == court.teamB.length) {
      return false;
    }

    _courts[courtIndex] = court.copyWith(
      teamA: teamA,
      teamB: teamB,
      status: CourtStatus.empty,
      startedAt: null,
    );

    notifyListeners();
    return true;
  }

  Court _withAutoStart(Court court) {
    final isFull = court.teamA.length == 2 && court.teamB.length == 2;

    if (isFull && court.status != CourtStatus.inProgress) {
      return court.copyWith(
        status: CourtStatus.inProgress,
        startedAt: DateTime.now(),
      );
    }

    return court;
  }

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
