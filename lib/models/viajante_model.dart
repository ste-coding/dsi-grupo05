class ViajanteModel {
  final String userId; // Ligação com o usuário correspondente
  final String bio;
  final int pontosExperiencia;

  ViajanteModel({
    required this.userId,
    required this.bio,
    this.pontosExperiencia = 0,
  });

  factory ViajanteModel.fromFirestore(Map<String, dynamic> data) {
    return ViajanteModel(
      userId: data['userId'],
      bio: data['bio'],
      pontosExperiencia: data['pontosExperiencia'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bio': bio,
      'pontosExperiencia': pontosExperiencia,
    };
  }
}
