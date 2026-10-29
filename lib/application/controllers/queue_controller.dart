import 'package:flutter/material.dart';

import '../../domain/models/queue.dart';
import '../../domain/models/queue_group.dart';
import '../services/local_storage_service.dart';

class QueueController extends ChangeNotifier {
  final List<QueueGroup> _queues = [];

  List<QueueGroup> get queues => List.unmodifiable(_queues);

  int get queueCount => _queues.length;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final savedQueues = await LocalStorageService.loadQueues();

    _queues
      ..clear()
      ..addAll(savedQueues);

    _initialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    if (!_initialized) return;
    await LocalStorageService.saveQueues(_queues);
  }

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
    _save();
  }

  // DELETE
  void deleteQueue(String id) {
    final originalLength = _queues.length;

    _queues.removeWhere((queue) => queue.id == id);

    if (_queues.length == originalLength) return;

    notifyListeners();
    _save();
  }

  // UPDATE
  void updateQueue(QueueGroup updatedQueue) {
    final index = _queues.indexWhere((queue) => queue.id == updatedQueue.id);

    if (index == -1) return;

    _queues[index] = updatedQueue;

    notifyListeners();
    _save();
  }

  // FIND THE SMALLEST AVAILABLE QUEUE NUMBER
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
