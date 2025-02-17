import 'package:cloud_firestore/cloud_firestore.dart';

class ItinerarioModel {
  String id;
  String userId;
  String titulo;
  DateTime startDate;
  DateTime endDate;
  String observations;
  String? imageUrl;
  List<ItinerarioItem> locais;

  ItinerarioModel({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.startDate,
    required this.endDate,
    required this.observations,
    this.imageUrl,
    required this.locais,
  });

  factory ItinerarioModel.fromFirestore(
      Map<String, dynamic> data, List<ItinerarioItem> locais) {
    return ItinerarioModel(
      id: data['id'],
      userId: data['userId'],
      titulo: data['titulo'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      observations: data['observations'] ?? '',
      imageUrl: data['imageUrl'],
      locais: locais,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'titulo': titulo,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'observations': observations,
      'imageUrl': imageUrl,
      'locais': locais.map((e) => e.toFirestore()).toList(),
    };
  }
}

class ItinerarioItem {
  String localId;
  String? localName;
  DateTime visitDate;
  String comment;
  String? itinerarioId;

  ItinerarioItem({
    required this.localId,
    this.localName,
    required this.visitDate,
    required this.comment,
    this.itinerarioId,
  });

  factory ItinerarioItem.fromFirestore(Map<String, dynamic> data) {
    return ItinerarioItem(
      localId: data['localId'],
      localName: data['localName'],
      visitDate: (data['visitDate'] as Timestamp).toDate(),
      comment: data['comment'],
      itinerarioId: data['itinerarioId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'localId': localId,
      'localName': localName,
      'visitDate': Timestamp.fromDate(visitDate),
      'comment': comment,
      'itinerarioId': itinerarioId,
    };
  }
}
