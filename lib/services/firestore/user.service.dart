import 'dart:typed_data';
import 'dart:convert'; 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Uint8List? profileImage;
  

  FirebaseAuth get auth => _auth;

  DocumentReference get userRef {
    return _firestore.collection('users').doc(_auth.currentUser!.uid);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      DocumentSnapshot docSnapshot = await userRef.get();
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Erro ao recuperar dados do usuário: $e");
      rethrow;
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    final querySnapshot = await _firestore.collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> isCpfRegistered(String cpf) async {
    final querySnapshot = await _firestore.collection('users')
        .where('cpf', isEqualTo: cpf)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> createUserDocument(User user, String nome, String cpf, Uint8List? profileImage) async {
    try {
      String? profilePictureBase64 = profileImage != null ? base64Encode(profileImage) : null;
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'nome': nome,
        'cpf': cpf,
        'profilePicture': profilePictureBase64,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Erro ao criar o documento do usuário: $e';
    }
  }
}