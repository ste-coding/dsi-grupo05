class AvaliacaoModel {
  final String id;
  final String localId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime timestamp;

  AvaliacaoModel({
    required this.id,
    required this.localId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  // Converte o modelo para um Map (para salvar no Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'localId': localId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }

  // Cria um modelo a partir de um Map (para ler do Firestore)
  factory AvaliacaoModel.fromFirestore(String id, Map<String, dynamic> data) {
    return AvaliacaoModel(
      id: id,
      localId: data['localId'],
      userId: data['userId'],
      userName: data['userName'],
      rating: data['rating'],
      comment: data['comment'],
      timestamp: data['timestamp'].toDate(),
    );
  }
}