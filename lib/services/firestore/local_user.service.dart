import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/local_user_model.dart';

class LocalUserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addLocal(LocalUserModel local) async {
    try {
      await _db.collection('locais_usuario').doc(local.id).set(local.toJson());
      await _updateMediaEstrelas(local.id); // Update mediaEstrelas
      print("Local adicionado com sucesso!");
    } catch (e) {
      _logFirestoreError(e);
    }
  }

  Future<void> deleteLocal(String localId) async {
    try {
      await _db.collection('locais_usuario').doc(localId).delete();
      await _updateMediaEstrelas(localId); // Update mediaEstrelas
      print("Local excluído com sucesso!");
    } catch (e) {
      _logFirestoreError(e);
    }
  }

  Future<void> updateLocal(LocalUserModel local) async {
    try {
      await _db.collection('locais_usuario').doc(local.id).update(local.toJson());
      await _updateMediaEstrelas(local.id); // Update mediaEstrelas
      print("Local atualizado com sucesso!");
    } catch (e) {
      _logFirestoreError(e);
    }
  }

  Future<void> _updateMediaEstrelas(String localId) async {
    try {
      final avaliacoesSnapshot = await _db.collection('locais_usuario').doc(localId).collection('avaliacoes').get();
      if (avaliacoesSnapshot.docs.isNotEmpty) {
        double totalEstrelas = 0;
        for (var doc in avaliacoesSnapshot.docs) {
          totalEstrelas += doc.data()['estrelas'];
        }
        double mediaEstrelas = totalEstrelas / avaliacoesSnapshot.docs.length;
        await _db.collection('locais_usuario').doc(localId).update({'mediaEstrelas': mediaEstrelas});
      } else {
        await _db.collection('locais_usuario').doc(localId).update({'mediaEstrelas': 0});
      }
    } catch (e) {
      _logFirestoreError(e);
    }
  }

  Future<void> addAvaliacao(String localId, Map<String, dynamic> avaliacao) async {
    try {
      await _db.collection('locais_usuario').doc(localId).collection('avaliacoes').add(avaliacao);
      await _updateMediaEstrelas(localId); // Update mediaEstrelas
    } catch (e) {
      _logFirestoreError(e);
    }
  }

  Future<void> updateAvaliacao(String localId, String avaliacaoId, Map<String, dynamic> avaliacao) async {
    try {
      await _db.collection('locais_usuario').doc(localId).collection('avaliacoes').doc(avaliacaoId).update(avaliacao);
      await _updateMediaEstrelas(localId); // Update mediaEstrelas
    } catch (e) {
      _logFirestoreError(e);
    }
  }

  Future<void> deleteAvaliacao(String localId, String avaliacaoId) async {
    try {
      await _db.collection('locais_usuario').doc(localId).collection('avaliacoes').doc(avaliacaoId).delete();
      await _updateMediaEstrelas(localId); // Update mediaEstrelas
    } catch (e) {
      _logFirestoreError(e);
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
      _logFirestoreError(e);
      return [];
    }
  }

  Future<double> getMediaEstrelas(String localId) async {
    try {
      final snapshot = await _db.collection('locais_usuario').doc(localId).get();
      if (snapshot.exists) {
        return (snapshot.data()?['mediaEstrelas'] ?? 0).toDouble();
      }
    } catch (e) {
      _logFirestoreError(e);
    }
    return 0.0;
  }

  Future<int> getTotalAvaliacoes(String localId) async {
    try {
      final snapshot = await _db.collection('locais_usuario').doc(localId).get();
      if (snapshot.exists) {
        return snapshot.data()?['totalAvaliacoes'] ?? 0;
      }
    } catch (e) {
      _logFirestoreError(e);
    }
    return 0;
  }

  void _logFirestoreError(dynamic error) {
    print("Erro no Firestore: $error");
  }
}