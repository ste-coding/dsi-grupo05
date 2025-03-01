class UserModel {
  final String uid;
  final String email;
  final String cpf;
  final String nome;

  UserModel({required this.uid, required this.email, required this.cpf, required this.nome});

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      cpf: data['cpf'],
      nome: data['nome'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'cpf': cpf,
      'nome': nome,
    };
  }
}
