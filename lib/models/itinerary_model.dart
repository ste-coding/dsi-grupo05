import 'package:cloud_firestore/cloud_firestore.dart';

class ItinerarioModel {
  final String id;
  final String userId;
  final String titulo;
  final List<ItinerarioItem> locais;

  ItinerarioModel({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.locais,
  });

  factory ItinerarioModel.fromFirestore(Map<String, dynamic> data) {
    var locais = (data['locais'] as List)
        .map((item) => ItinerarioItem.fromFirestore(item))
        .toList();

    return ItinerarioModel(
      id: data['id'],
      userId: data['userId'],
      titulo: data['titulo'],
      locais: locais,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'titulo': titulo,
      'locais': locais.map((e) => e.toFirestore()).toList(),
    };
  }
}

class ItinerarioItem {
  final String localId;
  final DateTime visitDate;
  final String comment;

  ItinerarioItem({
    required this.localId,
    required this.visitDate,
    required this.comment,
  });

  factory ItinerarioItem.fromFirestore(Map<String, dynamic> data) {
    return ItinerarioItem(
      localId: data['localId'],
      visitDate: (data['visitDate'] as Timestamp).toDate(),
      comment: data['comment'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'localId': localId,
      'visitDate': Timestamp.fromDate(visitDate),
      'comment': comment,
    };
  }
}
