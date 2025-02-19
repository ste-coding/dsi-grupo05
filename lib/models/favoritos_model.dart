import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritoModel {
  final String localId; // fsq_id do Foursquare
  final bool favorito;
  final Timestamp dataAdicionado;

  FavoritoModel({
    required this.localId,
    required this.favorito,
    required this.dataAdicionado,
  });

  factory FavoritoModel.fromFirestore(Map<String, dynamic> doc) {
    return FavoritoModel(
      localId: doc['localId'],
      favorito: doc['favorito'],
      dataAdicionado: doc['dataAdicionado'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'localId': localId,
      'favorito': favorito,
      'dataAdicionado': dataAdicionado,
    };
  }
}

