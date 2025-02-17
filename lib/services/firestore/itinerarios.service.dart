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

  Future<void> atualizarItinerario(
      String itinerarioId, Map<String, dynamic> data) async {
    try {
      if (itinerarioId.isEmpty) {
        throw Exception("ID do itinerário está vazio");
      }

      await itinerarios.doc(itinerarioId).update(data);
      print("Itinerário atualizado com sucesso!");
    } catch (e) {
      print("Erro ao atualizar itinerário: $e");
      rethrow;
    }
  }

  /// Adiciona um novo itinerário ao Firestore
  Future<void> addItinerario(Map<String, dynamic> itinerario) async {
    try {
      // Cria uma nova referência de documento com ID gerado automaticamente
      DocumentReference itinerarioRef = await itinerarios.add(itinerario);
      print("Itinerário adicionado com sucesso! ID: ${itinerarioRef.id}");

      // Atualiza o documento com o ID gerado
      await itinerarioRef.update({'id': itinerarioRef.id});
      print("ID do itinerário adicionado ao Firestore: ${itinerarioRef.id}");
    } catch (e) {
      print("Erro ao adicionar itinerário: $e");
      rethrow;
    }
  }

  /// Adiciona um local ao roteiro de um itinerário
  Future<void> addLocalToRoteiro(
      String itinerarioId, Map<String, dynamic> local) async {
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

  /// Obtém um itinerário com seus locais
  Future<ItinerarioModel> getItinerarioWithLocais(String itinerarioId) async {
    try {
      DocumentSnapshot itinerarioDoc =
          await itinerarios.doc(itinerarioId).get();

      if (!itinerarioDoc.exists) {
        throw Exception('Itinerário não encontrado para o ID: $itinerarioId');
      }

      var itinerarioData = itinerarioDoc.data() as Map<String, dynamic>;

      List<ItinerarioItem> locais = [];
      var locaisSnapshot =
          await itinerarios.doc(itinerarioId).collection('roteiro').get();

      for (var localDoc in locaisSnapshot.docs) {
        var localData = localDoc.data();
        locais.add(ItinerarioItem.fromFirestore(localData));
      }

      return ItinerarioModel.fromFirestore(itinerarioData, locais);
    } catch (e) {
      print("Erro ao carregar itinerário com locais: $e");
      throw Exception('Erro ao carregar itinerário: $e');
    }
  }

  /// Retorna um stream dos itinerários ordenados por data de início
  Stream<QuerySnapshot> getItinerariosStream() {
    return itinerarios.orderBy('startDate', descending: true).snapshots();
  }

  /// Obtém os locais de um itinerário
  Future<QuerySnapshot> getLocaisByItinerarioId(String itinerarioId) async {
    try {
      return await itinerarios.doc(itinerarioId).collection('roteiro').get();
    } catch (e) {
      print("Erro ao obter locais para itinerário $itinerarioId: $e");
      rethrow;
    }
  }

  /// Exclui um itinerário do Firestore
  Future<void> deleteItinerario(String itinerarioId) async {
    try {
      await itinerarios.doc(itinerarioId).delete();
      print("Itinerário $itinerarioId excluído com sucesso.");
    } catch (e) {
      print("Erro ao excluir itinerário: $e");
      rethrow;
    }
  }

  /// Cria um itinerário e retorna o ID gerado
  Future<String> criarItinerario({
    required DateTime startDate,
    required DateTime endDate,
    required String observations,
  }) async {
    try {
      // Cria uma nova referência de documento com ID gerado automaticamente
      DocumentReference itinerarioRef = await itinerarios.add({
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'observations': observations,
      });

      String itineraryId = itinerarioRef.id; // ID gerado automaticamente
      print("Itinerário criado com sucesso! ID: $itineraryId");

      // Atualiza o documento com o ID gerado
      await itinerarioRef.update({'id': itineraryId});
      print("ID do itinerário adicionado ao Firestore: $itineraryId");

      return itineraryId; // Retorna o ID gerado
    } catch (e) {
      print("Erro ao criar itinerário: $e");
      rethrow;
    }
  }
}
