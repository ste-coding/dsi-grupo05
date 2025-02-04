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
      final itinerarioDoc = await itinerarios.doc(itinerarioId).get();
      if (!itinerarioDoc.exists) {
        throw Exception('Itinerário não encontrado');
      }

      final itinerarioData = itinerarioDoc.data() as Map<String, dynamic>;

      final locaisSnapshot = await itinerarios
          .doc(itinerarioId)
          .collection('roteiro')
          .where('itinerarioId', isEqualTo: itinerarioId)
          .get();

      if (locaisSnapshot.docs.isEmpty) {
        print("Nenhum local encontrado para o itinerário.");
      }

      List<ItinerarioItem> locais = locaisSnapshot.docs
          .map((doc) => ItinerarioItem.fromFirestore(doc.data()))
          .toList();

      return ItinerarioModel.fromFirestore({
        ...itinerarioData,
        'locais': locais,
      });
    } catch (e) {
      print("Erro ao carregar itinerário e locais: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getItinerariosStream() {
    return itinerarios.orderBy('startDate', descending: true).snapshots();
  }
}
