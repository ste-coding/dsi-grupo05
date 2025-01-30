import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setDocument(String collectionPath, String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).set(data);
    } catch (e) {
      print("Erro ao definir documento: $e");
      rethrow;
    }
  }
}
