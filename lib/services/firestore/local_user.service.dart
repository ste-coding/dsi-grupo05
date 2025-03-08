import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/local_user_model.dart';

class LocalUserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addLocal(LocalUserModel local) async {
    try {
      await _db.collection('locais_usuario').doc(local.id).set(local.toJson());
      print("Local adicionado com sucesso!");
    } catch (e) {
      print("Erro ao adicionar local: $e");
    }
  }

  Future<void> deleteLocal(String localId) async {
    try {
      await _db.collection('locais_usuario').doc(localId).delete();
      print("Local excluído com sucesso!");
    } catch (e) {
      print("Erro ao excluir local: $e");
    }
  }

  Future<void> updateLocal(LocalUserModel local) async {
    try {
      await _db.collection('locais_usuario').doc(local.id).update(local.toJson());
      print("Local atualizado com sucesso!");
    } catch (e) {
      print("Erro ao atualizar local: $e");
    }
  }

  Future<List<LocalUserModel>> fetchLocaisUsuario() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return [];

    try {
      final snapshot = await _db
          .collection('locais_usuario')
          .where('usuarioId', isEqualTo: usuario.uid)
          .get();

      return snapshot.docs.map((doc) => LocalUserModel.fromJson(doc.data())).toList();
    } catch (e) {
      print("Erro ao buscar locais: $e");
      return [];
    }
  }
}