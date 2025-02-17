import 'package:cloud_firestore/cloud_firestore.dart';

class ChecklistService {
  final CollectionReference checklist;

  ChecklistService(String userId, String itinerarioId)
      : assert(userId.isNotEmpty, 'userId não pode ser vazio'),
        assert(itinerarioId.isNotEmpty, 'itinerarioId não pode ser vazio'),
        checklist = FirebaseFirestore.instance
            .collection('viajantes')
            .doc(userId)
            .collection('itinerarios') // Nova coleção de itinerários
            .doc(itinerarioId) // Referência ao itinerário específico
            .collection('checklist'); // Checklist para este itinerário

  // Adiciona uma tarefa específica ao checklist do itinerário
  Future<void> addTask(Map<String, dynamic> task) async {
    try {
      await checklist.add({
        'task': task['task'],
        'completed': false,
        'timestamp': Timestamp.now(),
        'itinerarioId': task['itinerarioId'], // Referência ao itinerário
      });
    } catch (e) {
      print("Erro ao adicionar tarefa: $e");
      rethrow;
    }
  }

  // Recupera as tarefas de um checklist específico
  Stream<QuerySnapshot> getChecklistStream() {
    return checklist.orderBy('timestamp', descending: true).snapshots();
  }

  // Atualiza o status de completado de uma tarefa
  Future<void> updateTaskStatus(String docID, bool completed) async {
    try {
      await checklist.doc(docID).update({
        'completed': completed,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print("Erro ao atualizar tarefa: $e");
      rethrow;
    }
  }

  // Atualiza o texto de uma tarefa
  Future<void> updateTask(String docID, String updatedTask) async {
    try {
      await checklist.doc(docID).update({
        'task': updatedTask,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print("Erro ao editar tarefa: $e");
      rethrow;
    }
  }

  // Exclui uma tarefa
  Future<void> deleteTask(String docID) async {
    try {
      await checklist.doc(docID).delete();
    } catch (e) {
      print("Erro ao excluir tarefa: $e");
      rethrow;
    }
  }
}
