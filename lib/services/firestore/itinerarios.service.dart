import 'package:cloud_firestore/cloud_firestore.dart';

class ItinerariosService {
  final CollectionReference itinerarios;

  ItinerariosService(String userId)
      : itinerarios = FirebaseFirestore.instance
            .collection('viajantes')
            .doc(userId)
            .collection('itinerarios');

  Future<void> addItinerario(Map<String, dynamic> itinerario) async {
    try {
      await itinerarios.add(itinerario);
    } catch (e) {
      print("Erro ao adicionar itinerário: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getItinerariosStream() {
    return itinerarios.orderBy('startDate', descending: true).snapshots();
  }
}
