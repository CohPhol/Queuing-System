import 'queue.dart';

class QueueGroup {
  final String id;
  final String name;
  final Queue queue;

  QueueGroup({required this.id, required this.name, required this.queue});

  QueueGroup copyWith({String? id, String? name, Queue? queue}) {
    return QueueGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      queue: queue ?? this.queue,
    );
  }
}
