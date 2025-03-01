class ViajanteModel {
  final String userId;
  final String bio;

  ViajanteModel({
    required this.userId,
    required this.bio,
  });

  factory ViajanteModel.fromFirestore(Map<String, dynamic> data) {
    return ViajanteModel(
      userId: data['userId'],
      bio: data['bio'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bio': bio,
    };
  }
}
