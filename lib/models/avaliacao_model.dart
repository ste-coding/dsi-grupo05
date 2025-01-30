import 'package:cloud_firestore/cloud_firestore.dart';

class AvaliacaoModel {
  final String id;
  final String comentario;
  final String userId;
  final DateTime data;
  final int nota;

  AvaliacaoModel({
    required this.id,
    required this.comentario,
    required this.userId,
    required this.data,
    required this.nota,
  });

  factory AvaliacaoModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AvaliacaoModel(
      id: id,
      comentario: data['comentario'],
      userId: data['userId'],
      data: (data['data'] as Timestamp).toDate(),
      nota: data['nota'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'comentario': comentario,
      'userId': userId,
      'data': data,
      'nota': nota,
    };
  }
}
