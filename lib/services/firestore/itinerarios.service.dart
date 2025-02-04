import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/itinerario_model.dart';

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

      await itinerarioRef.update({'id': itinerarioRef.id});
      print("ID do itinerário adicionado ao Firestore: ${itinerarioRef.id}");
    } catch (e) {
      print("Erro ao adicionar itinerário: $e");
      rethrow;
    }
  }

  Future<void> addLocalToRoteiro(String itinerarioId, Map<String, dynamic> local) async {
    try {
      final itinerarioDoc = await itinerarios.doc(itinerarioId).get();
      if (!itinerarioDoc.exists) {
        print("Erro: itinerário não encontrado para o ID: $itinerarioId");
        throw Exception("Itinerário não encontrado");
      }

      print("Itinerário encontrado. Adicionando local ao roteiro...");

      final localWithItinerarioId = {
        ...local,
        'itinerarioId': itinerarioId,
      };

      await itinerarios
          .doc(itinerarioId)
          .collection('roteiro')
          .add(localWithItinerarioId);

      print("Local adicionado ao roteiro do itinerário com sucesso.");
    } catch (e) {
      print("Erro ao adicionar local ao roteiro: $e");
      rethrow;
    }
  }

  Future<ItinerarioModel> getItinerarioWithLocais(String itinerarioId) async {
  try {
    DocumentSnapshot itinerarioDoc = await _firestore
        .collection('viajantes')
        .doc(itinerarioId)
        .get();

    if (!itinerarioDoc.exists) {
      throw Exception('Itinerário não encontrado para o ID: $itinerarioId');
    }

    var itinerarioData = itinerarioDoc.data() as Map<String, dynamic>;

    List<ItinerarioItem> locais = [];
    var locaisSnapshot = await _firestore
        .collection('viajantes')
        .doc(itinerarioId)
        .collection('roteiro')
        .get();

    for (var localDoc in locaisSnapshot.docs) {
      var localData = localDoc.data() as Map<String, dynamic>;
      locais.add(ItinerarioItem.fromFirestore(localData));
    }

    return ItinerarioModel.fromFirestore(itinerarioData, locais);
  } catch (e) {
    print("Erro ao carregar itinerário com locais: $e");
    throw Exception('Erro ao carregar itinerário: $e');
  }
}
  Stream<QuerySnapshot> getItinerariosStream() {
    return itinerarios.orderBy('startDate', descending: true).snapshots();
  }

  Future<QuerySnapshot> getLocaisByItinerarioId(String itinerarioId) async {
    try {
      return await _firestore
          .collection('viajantes')
          .doc(itinerarioId)
          .collection('roteiro')
          .get();
    } catch (e) {
      print("Erro ao obter locais para itinerário $itinerarioId: $e");
      rethrow;
    }
  }
}
