import 'package:flutter/material.dart';

import '../../domain/models/player.dart';
import '../../domain/enums/payment_status.dart';
import '../../domain/enums/player_availability.dart';
import '../services/local_storage_service.dart';

class PlayerController extends ChangeNotifier {
  final List<Player> _players = [];

  List<Player> get players => List.unmodifiable(_players);

  bool _initialized = false;

  // RESTORE SAVED PLAYERS
  Future<void> initialize() async {
    if (_initialized) return;

    final savedPlayers = await LocalStorageService.loadPlayers();

    _players
      ..clear()
      ..addAll(savedPlayers);

    _initialized = true;
    notifyListeners();
  }

  // SAVE PLAYERS
  Future<void> _save() async {
    if (!_initialized) return;

    await LocalStorageService.savePlayers(_players);
  }

  // CREATE
  void addPlayer(Player player) {
    _players.add(player);
    notifyListeners();
    _save();
  }

  // UPDATE
  void updatePlayer(Player updated) {
    final index = _players.indexWhere((p) => p.id == updated.id);

    if (index == -1) return;

    _players[index] = updated;

    notifyListeners();
    _save();
  }

  // DELETE
  void deletePlayer(String id) {
    final originalLength = _players.length;

    _players.removeWhere((p) => p.id == id);

    if (_players.length == originalLength) return;

    notifyListeners();
    _save();
  }

  // TOGGLE PAYMENT STATUS
  void togglePayment(String playerId) {
    final index = _players.indexWhere((p) => p.id == playerId);

    if (index == -1) return;

    final player = _players[index];

    _players[index] = player.copyWith(
      paymentStatus: player.paymentStatus == PaymentStatus.paid
          ? PaymentStatus.unpaid
          : PaymentStatus.paid,
    );

    notifyListeners();
    _save();
  }

  // TOGGLE AVAILABILITY
  void toggleAvailability(String playerId) {
    final index = _players.indexWhere((p) => p.id == playerId);

    if (index == -1) return;

    final player = _players[index];

    final next = switch (player.availability) {
      PlayerAvailability.present => PlayerAvailability.absent,
      PlayerAvailability.absent => PlayerAvailability.present,
    };

    _players[index] = player.copyWith(availability: next);

    notifyListeners();
    _save();
  }

  // READ SINGLE PLAYER
  Player? getById(String id) {
    for (final player in _players) {
      if (player.id == id) return player;
    }

    return null;
  }
}
