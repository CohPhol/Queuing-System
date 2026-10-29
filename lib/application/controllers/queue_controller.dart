import 'package:flutter/material.dart';

import '../../domain/models/queue.dart';
import '../../domain/models/queue_group.dart';

class QueueController extends ChangeNotifier {
  final List<QueueGroup> _queues = [];

  List<QueueGroup> get queues => List.unmodifiable(_queues);

  int get queueCount => _queues.length;

  // CREATE
  void addQueue() {
    final queueNumber = _nextQueueNumber();

    _queues.add(
      QueueGroup(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Queue $queueNumber',
        queue: Queue(entries: []),
      ),
    );

    notifyListeners();
  }

  // DELETE
  void deleteQueue(String id) {
    _queues.removeWhere((queue) => queue.id == id);
    notifyListeners();
  }

  // UPDATE
  void updateQueue(QueueGroup updatedQueue) {
    final index = _queues.indexWhere((queue) => queue.id == updatedQueue.id);

    if (index == -1) return;

    _queues[index] = updatedQueue;
    notifyListeners();
  }

  int _nextQueueNumber() {
    final existingNumbers = _queues
        .map((queue) {
          final match = RegExp(r'^Queue (\d+)$').firstMatch(queue.name);
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
