import 'queue_entry.dart';

class Queue {
  final List<QueueEntry> entries;

  Queue({required this.entries});

  Queue add(QueueEntry entry) {
    return Queue(entries: [...entries, entry]);
  }

  Queue remove(String entryId) {
    return Queue(entries: entries.where((e) => e.id != entryId).toList());
  }

  Queue reorder(int oldIndex, int newIndex) {
    final updated = [...entries];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    return Queue(entries: updated);
  }
}
