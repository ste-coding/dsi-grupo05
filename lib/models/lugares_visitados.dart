class VisitadosModel {
  final String userId;
  final String localId;
  final bool visited;

  VisitadosModel({
    required this.userId,
    required this.localId,
    required this.visited,
  });

  factory VisitadosModel.fromFirestore(Map<String, dynamic> data) {
    return VisitadosModel(
      userId: data['userId'],
      localId: data['localId'],
      visited: data['visited'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'localId': localId,
      'visited': visited,
    };
  }
}
