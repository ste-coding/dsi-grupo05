import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmailPassword(String email, String password) async {
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  Future<User?> registerWithEmailPassword(String email, String password, String cpf, String nome) async {
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;

    if (user != null) {
      UserModel userModel = UserModel(uid: user.uid, email: email, cpf: cpf, nome: nome);
      await _firestore.collection('users').doc(user.uid).set(userModel.toFirestore());
    }

    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
