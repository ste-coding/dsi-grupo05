import 'package:cloud_firestore/cloud_firestore.dart';

class ItinerarioModel {
  final String id;
  final String userId;
  final String titulo;
  final DateTime startDate;
  final DateTime endDate;
  final String observations;
  final String imageUrl;
  final List<ItinerarioItem> locais;

  ItinerarioModel({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.startDate,
    required this.endDate,
    required this.observations,
    required String imageUrl,
    required this.locais,
  }) : imageUrl = imageUrl.isNotEmpty ? imageUrl : 'assets/images/placeholder_image.png';

  factory ItinerarioModel.fromFirestore(Map<String, dynamic> data, List<ItinerarioItem> locais) {
    return ItinerarioModel(
      id: data['id'],
      userId: data['userId'],
      titulo: data['titulo'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      observations: data['observations'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
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
      'imageUrl': imageUrl == 'assets/images/placeholder_image.png' ? '' : imageUrl,
      'locais': locais.map((e) => e.toFirestore()).toList(),
    };
  }
}

class ItinerarioItem {
  final String localId;
  final String? localName;
  final DateTime visitDate;
  final String comment;
  final String? itinerarioId;

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
