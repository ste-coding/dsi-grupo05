import 'package:cloud_firestore/cloud_firestore.dart';

class ItinerariosService {
  final CollectionReference itinerarios;

  ItinerariosService(String userId)
      : itinerarios = FirebaseFirestore.instance
            .collection('viajantes')
            .doc(userId)   // Aqui você usa o userId diretamente
            .collection('itinerarios');  // Subcoleção de itinerários do usuário

  Future<void> addItinerario(Map<String, dynamic> itinerario) async {
    try {
      // Aqui você deve garantir que está adicionando o itinerário de forma correta
      // Exemplo de uso do método add
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
