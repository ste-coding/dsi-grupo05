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
}