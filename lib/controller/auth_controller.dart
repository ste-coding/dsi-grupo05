import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/models/viajante_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return userCredential.user;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return null;
    }
  }

  Future<User?> registerWithEmailPassword(String email, String password, String cpf, String nome) async {
    try {
      if (await isEmailRegistered(email)) {
        print('Email já registrado.');
        return null;
      }
      if (await isCpfRegistered(cpf)) {
        print('CPF já registrado.');
        return null;
      }

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          cpf: cpf,
          nome: nome,
        );

        await _firestore.collection('users').doc(user.uid).set(userModel.toFirestore());

        ViajanteModel viajanteModel = ViajanteModel(
          userId: user.uid,
          bio: '',
        );
        await _firestore.collection('viajantes').doc(user.uid).set(viajanteModel.toFirestore());
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print('Erro ao registrar: ${e.message}');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPasswordWithEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<bool> isCpfRegistered(String cpf) async {
    final querySnapshot = await _firestore.collection('users').where('cpf', isEqualTo: cpf).get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> isEmailRegistered(String email) async {
    final querySnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> updateBio(String userId, String novaBio) async {
    try {
      await _firestore.collection('viajantes').doc(userId).update({
        'bio': novaBio,
      });
    } catch (e) {
      print('Erro ao atualizar bio: $e');
    }
  }
}
