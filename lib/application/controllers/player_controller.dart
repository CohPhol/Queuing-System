import 'package:flutter/material.dart';
import '../../domain/models/player.dart';

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

  // READ (single)
  Player? getById(String id) {
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
