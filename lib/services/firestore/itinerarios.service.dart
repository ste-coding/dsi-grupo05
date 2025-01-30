import 'package:cloud_firestore/cloud_firestore.dart';

class ItinerariosService {
  final CollectionReference itinerarios;

  ItinerariosService(String userId) : itinerarios = FirebaseFirestore.instance.collection('viajantes').doc(userId).collection('itinerarios');

  Future<void> addItinerario(Map<String, dynamic> itinerario) async {
    try {
      await itinerarios.add({
        'titulo': itinerario['titulo'],
        'horario': itinerario['horario'],
        'localizacao': itinerario['localizacao'],
        'observacoes': itinerario['observacoes'] ?? '',
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print("Erro ao adicionar itinerário: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getItinerariosStream() {
    return itinerarios.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateItinerario(String docID, Map<String, dynamic> newItinerario) async {
    try {
      await itinerarios.doc(docID).update({
        'titulo': newItinerario['titulo'],
        'horario': newItinerario['horario'],
        'localizacao': newItinerario['localizacao'],
        'observacoes': newItinerario['observacoes'] ?? '',
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print("Erro ao atualizar itinerário: $e");
      rethrow;
    }
  }

  Future<void> deleteItinerario(String docID) async {
    try {
      await itinerarios.doc(docID).delete();
    } catch (e) {
      print("Erro ao excluir itinerário: $e");
      rethrow;
    }
  }
}
