import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  
  // pegar coleção de anotações
  final CollectionReference notes =
  FirebaseFirestore.instance.collection('favoritos');

  // CRIAR: add anotação
  Future<void> addNote(String note){
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  // LER: pegar anotação do banco de dados 
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
  Future<void> deleteNote(String docID){
    return notes.doc(docID).delete();
  }

}