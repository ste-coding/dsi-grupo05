import 'package:cloud_firestore/cloud_firestore.dart';
class ItinerariosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference itinerarios;

  ItinerariosService(String userId)
      : itinerarios = FirebaseFirestore.instance
            .collection('viajantes')
            .doc(userId)
            .collection('itinerarios');

  Future<void> addItinerario(Map<String, dynamic> itinerario) async {
    try {
      DocumentReference itinerarioRef = await itinerarios.add(itinerario);
      print("Itinerário adicionado com sucesso! ID: ${itinerarioRef.id}");
    } catch (e) {
      print("Erro ao adicionar itinerário: $e");
      rethrow;
    }
  }

  Future<void> addLocalToRoteiro(String itinerarioId, Map<String, dynamic> local) async {
    try {
      await itinerarios
          .doc(itinerarioId)
          .collection('roteiro')
          .add(local);
      print("Local adicionado ao roteiro do itinerário.");
    } catch (e) {
      print("Erro ao adicionar local ao roteiro: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getItinerariosStream() {
    return itinerarios.orderBy('startDate', descending: true).snapshots();
  }
}
