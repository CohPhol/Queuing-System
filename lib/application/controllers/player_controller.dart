import 'package:flutter/material.dart';
import '../../domain/models/player.dart';
import '../../domain/enums/payment_status.dart';
import '../../domain/enums/player_availability.dart';

class PlayerController extends ChangeNotifier {
  final List<Player> _players = [];

  List<Player> get players => List.unmodifiable(_players);

  // CREATE
  void addPlayer(Player player) {
    _players.add(player);
    notifyListeners();
  }

  // UPDATE
  void updatePlayer(Player updated) {
    final index = _players.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _players[index] = updated;
      notifyListeners();
    }
  }

  // DELETE
  void deletePlayer(String id) {
    _players.removeWhere((p) => p.id == id);
    notifyListeners();
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
  }

  // TOGGLE AVAILABILITY
  void toggleAvailability(String playerId) {
    final index = _players.indexWhere((p) => p.id == playerId);
    if (index == -1) return;

    final player = _players[index];

    PlayerAvailability next;

    switch (player.availability) {
      case PlayerAvailability.present:
        next = PlayerAvailability.absent;
        break;
      case PlayerAvailability.absent:
        next = PlayerAvailability.present;
        break;
    }

    _players[index] = player.copyWith(availability: next);

    notifyListeners();
  }

  // READ (single)
  Player? getById(String id) {
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
