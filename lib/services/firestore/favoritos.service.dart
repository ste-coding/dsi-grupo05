import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/favorites_model.dart';

class FavoritosService {
  final CollectionReference favoritos;

  FavoritosService(String userId)
      : favoritos = FirebaseFirestore.instance
            .collection('viajantes')
            .doc(userId)
            .collection('favoritos');

  Future<void> addFavorito(String localId) async {
    try {
      final favorito = FavoritoModel(
        localId: localId,
        favorito: true,
        dataAdicionado: Timestamp.now(),
      );
      await favoritos.doc(localId).set(favorito.toFirestore());
    } catch (e) {
      throw Exception("Erro ao adicionar favorito: $e");
    }
  }

  Future<void> removeFavorito(String localId) async {
    try {
      await favoritos.doc(localId).update({'favorito': false});
    } catch (e) {
      throw Exception("Erro ao remover favorito: $e");
    }
  }

  Future<bool> checkIfFavoritoExists(String localId) async {
    try {
      final docSnapshot = await favoritos.doc(localId).get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data['favorito'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      throw Exception("Erro ao verificar se o favorito já existe: $e");
    }
  }

  Stream<List<FavoritoModel>> getFavoritosStream() {
    return favoritos.where('favorito', isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FavoritoModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}