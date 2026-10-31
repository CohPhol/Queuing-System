import 'queue_entry.dart';
import 'package:queuing_system/domain/enums/queue_team.dart';

class Queue {
  final List<QueueEntry> entries;

  Queue({required this.entries});

  List<QueueEntry> get teamAEntries {
    return entries.where((entry) => entry.team == QueueTeam.teamA).toList()
      ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));
  }

  List<QueueEntry> get teamBEntries {
    return entries.where((entry) => entry.team == QueueTeam.teamB).toList()
      ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));
  }

  bool get isTeamAFull => teamAEntries.length >= 2;

  bool get isTeamBFull => teamBEntries.length >= 2;

  bool get isFull => isTeamAFull && isTeamBFull;

  bool get isReady => teamAEntries.length == 2 && teamBEntries.length == 2;

  Queue add(QueueEntry entry) {
    final teamEntries = entry.team == QueueTeam.teamA
        ? teamAEntries
        : teamBEntries;

    if (teamEntries.length >= 2) {
      throw StateError(
        '${entry.team == QueueTeam.teamA ? 'Team A' : 'Team B'} is full.',
      );
    }

    if (teamEntries.any((existing) => existing.slotIndex == entry.slotIndex)) {
      throw StateError('This slot is already occupied.');
    }

    if (entries.any((existing) => existing.player.id == entry.player.id)) {
      throw StateError('This player is already in this queue.');
    }

    return Queue(entries: [...entries, entry]);
  }

  Queue copyWith({List<QueueEntry>? entries}) {
    return Queue(entries: entries ?? this.entries);
  }

  Queue remove(String entryId) {
    return Queue(
      entries: entries.where((entry) => entry.id != entryId).toList(),
    );
  }

  Queue reorder(int oldIndex, int newIndex) {
    final updated = [...entries];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    return Queue(entries: updated);
  }
}
