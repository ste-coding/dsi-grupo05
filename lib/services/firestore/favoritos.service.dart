import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/favoritos_model.dart';
import '../../models/local_model.dart';

class FavoritosService with ChangeNotifier {
  final CollectionReference favoritos;

  FavoritosService(String userId)
      : favoritos = FirebaseFirestore.instance
            .collection('viajantes')
            .doc(userId)
            .collection('favoritos');

  Future<void> addFavorito(LocalModel local) async {
    try {
      final favorito = {
        'localId': local.id,
        'nome': local.nome,
        'imagem': local.imagem,
        'categoria': local.categoria,
        'cidade': local.cidade,
        'estado': local.estado,
        'latitude': local.latitude,
        'longitude': local.longitude,
        'mediaEstrelas': local.mediaEstrelas,
        'totalAvaliacoes': local.totalAvaliacoes,
        'favorito': true,
        'dataAdicionado': Timestamp.now(),
      };

      await favoritos.doc(local.id).set(favorito);
      notifyListeners(); // Notificar sobre a mudança
    } catch (e) {
      throw Exception("Erro ao adicionar favorito: $e");
    }
  }

  Future<void> removeFavorito(String localId) async {
    try {
      await favoritos.doc(localId).update({'favorito': false});
      notifyListeners(); // Notificar sobre a mudança
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

  Stream<List<LocalModel>> getFavoritosStream() {
    return favoritos
        .where('favorito', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LocalModel(
          id: data['localId'],
          nome: data['nome'],
          descricao: '',
          imagem: data['imagem'],
          categoria: data['categoria'],
          cidade: data['cidade'],
          estado: data['estado'],
          latitude: data['latitude'],
          longitude: data['longitude'],
          mediaEstrelas: data['mediaEstrelas'],
          totalAvaliacoes: data['totalAvaliacoes'],
        );
      }).toList();
    });
  }
}