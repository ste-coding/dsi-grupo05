import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  // Referência aos favoritos do usuário
  CollectionReference get notes {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favoritos');
  }

  // CRIAR: adicionar anotação
  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  // LER: pegar as anotações do banco de dados do usuário
  Stream<QuerySnapshot> getNotesStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  // ATUALIZAR: atualizar a anotação, dado o id
  Future<void> updateNote(String docID, String newNote) {
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  // REMOVER: remover a anotação, dado o id
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }

  // Referência aos pontos turísticos
  CollectionReference get touristSpots {
    return FirebaseFirestore.instance.collection('ponto_turistico');
  }

  // Stream para pegar os pontos turísticos
  Stream<QuerySnapshot> getTouristSpotsStream({DocumentSnapshot? lastVisible}) {
    Query query = touristSpots.orderBy('name').limit(10);

    if (lastVisible != null) {
      query = query.startAfterDocument(lastVisible);
    }

    return query.snapshots();
  }

  // Referência ao documento do viajante
  DocumentReference get viajanteRef {
    return FirebaseFirestore.instance.collection('viajantes').doc(userId);
  }

  // Referência à subcoleção de itinerários
  CollectionReference get itinerarios {
    return viajanteRef.collection('itinerarios');
  }

  // CRUD para Itinerários

  // CRIAR: adicionar itinerário
  Future<void> addItinerario(Map<String, String> itinerario) {
    return itinerarios.add({
      'titulo': itinerario['titulo'],
      'horario': itinerario['horario'],
      'localizacao': itinerario['localizacao'],
      'observacoes': itinerario['observacoes'] ?? '',
      'timestamp': Timestamp.now(),
    });
  }

  // LER: pegar os itinerários
  Stream<QuerySnapshot> getItinerariosStream() {
    return itinerarios.orderBy('timestamp', descending: true).snapshots();
  }

  // ATUALIZAR: atualizar o itinerário
  Future<void> updateItinerario(
      String docID, Map<String, String> newItinerario) {
    return itinerarios.doc(docID).update({
      'titulo': newItinerario['titulo'],
      'horario': newItinerario['horario'],
      'localizacao': newItinerario['localizacao'],
      'observacoes': newItinerario['observacoes'] ?? '',
      'timestamp': Timestamp.now(),
    });
  }

  // REMOVER: excluir itinerário
  Future<void> deleteItinerario(String docID) {
    return itinerarios.doc(docID).delete();
  }

  // Referência à subcoleção de checklist do usuário
  CollectionReference get checklist {
    return viajanteRef.collection('checklist');
  }

  // CRUD para Checklist

  // CRIAR: adicionar tarefa ao checklist
  Future<void> addTask(String task) async {
    try {
      await checklist.add({
        'task': task,
        'completed': false,
        'timestamp': Timestamp.now(),
      });
      print("Tarefa adicionada com sucesso!");
    } catch (e) {
      print("Erro ao adicionar tarefa: $e");
      throw e;
    }
  }

  // LER: pegar as tarefas do checklist do usuário
  Stream<QuerySnapshot> getChecklistStream() {
    return checklist.orderBy('timestamp', descending: true).snapshots();
  }

  // ATUALIZAR: atualizar status da tarefa (completa ou não)
  Future<void> updateTaskStatus(String docID, bool completed) async {
    try {
      await checklist.doc(docID).update({
        'completed': completed,
        'timestamp': Timestamp.now(),
      });
      print("Tarefa atualizada com sucesso!");
    } catch (e) {
      print("Erro ao atualizar tarefa: $e");
      throw e;
    }
  }

  // ATUALIZAR: editar a descrição da tarefa
  Future<void> editTask(String docID, String updatedTask) async {
    try {
      await checklist.doc(docID).update({
        'task': updatedTask,
        'timestamp': Timestamp.now(),
      });
      print("Tarefa editada com sucesso!");
    } catch (e) {
      print("Erro ao editar tarefa: $e");
      throw e;
    }
  }

  // REMOVER: excluir tarefa do checklist
  Future<void> deleteTask(String docID) async {
    try {
      await checklist.doc(docID).delete();
      print("Tarefa excluída com sucesso!");
    } catch (e) {
      print("Erro ao excluir tarefa: $e");
      throw e;
    }
  }
}
