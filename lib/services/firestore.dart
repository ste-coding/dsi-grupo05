import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get notes {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection('favoritos');
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
    final notesStream =
      notes.orderBy('timestamp', descending: true).snapshots();

    return notesStream;
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

  CollectionReference get touristSpots {
    return FirebaseFirestore.instance.collection('ponto_turistico');
  }

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
  Future<void> addItinerario(Map<String, String> itinerario) {
    return itinerarios.add({
      'titulo': itinerario['titulo'],
      'horario': itinerario['horario'],
      'localizacao': itinerario['localizacao'],
      'observacoes': itinerario['observacoes'] ?? '',
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getItinerariosStream() {
    return itinerarios.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateItinerario(String docID, Map<String, String> newItinerario) {
    return itinerarios.doc(docID).update({
      'titulo': newItinerario['titulo'],
      'horario': newItinerario['horario'],
      'localizacao': newItinerario['localizacao'],
      'observacoes': newItinerario['observacoes'] ?? '',
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteItinerario(String docID) {
    return itinerarios.doc(docID).delete();
  }
}