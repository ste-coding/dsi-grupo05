class ChecklistModel {
  final String id;
  final String itinerarioId;
  final String task;
  final bool completed;

  ChecklistModel({
    required this.id,
    required this.itinerarioId,
    required this.task,
    required this.completed,
  });

  factory ChecklistModel.fromFirestore(Map<String, dynamic> data) {
    return ChecklistModel(
      id: data['id'],
      itinerarioId: data['itinerarioId'],
      task: data['task'],
      completed: data['completed'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'itinerarioId': itinerarioId,
      'task': task,
      'completed': completed,
    };
  }
}
