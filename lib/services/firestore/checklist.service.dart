import 'package:cloud_firestore/cloud_firestore.dart';

class ChecklistService {
  final CollectionReference checklist;

  ChecklistService(String userId)
      : assert(userId.isNotEmpty, 'userId não pode ser vazio'),
        checklist = FirebaseFirestore.instance
            .collection('viajantes')
            .doc(userId)
            .collection('checklist');

  Future<void> addTask(Map<String, dynamic> task) async {
    try {
      await checklist.add({
        'task': task['task'],
        'completed': false,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print("Erro ao adicionar tarefa: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getChecklistStream() {
    return checklist.orderBy('timestamp', descending: true).snapshots();
  }

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

  Future<void> deleteTask(String docID) async {
    try {
      await checklist.doc(docID).delete();
    } catch (e) {
      print("Erro ao excluir tarefa: $e");
      rethrow;
    }
  }
}
