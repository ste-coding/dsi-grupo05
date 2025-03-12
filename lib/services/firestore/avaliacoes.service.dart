import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvaliacoesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _obterReferenciasAvaliacoes(String localId) {
    return _firestore.collection('locais').doc(localId).collection('avaliacoes');
  }

  Future<User?> _verificarUsuarioAutenticado() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }
    return user;
  }

  Future<void> salvarAvaliacao(String localId, Map<String, dynamic> avaliacao, {String? docId}) async {
    final user = await _verificarUsuarioAutenticado();
    if (user == null) return;

    final avaliacoesRef = _obterReferenciasAvaliacoes(localId);
    final data = {
      'userId': user.uid,
      'nomeUsuario': avaliacao['nomeUsuario'],
      'comentario': avaliacao['comentario'],
      'estrelas': avaliacao['estrelas'],
      'data': FieldValue.serverTimestamp(),
    };

    if (docId != null) {
      await avaliacoesRef.doc(docId).update(data);
    } else {
      await avaliacoesRef.add(data);
    }

    _calcularEMediaEstrelas(localId);
  }

  Future<List<Map<String, dynamic>>> carregarAvaliacoes(String localId) async {
    final avaliacoesRef = _obterReferenciasAvaliacoes(localId);
    final querySnapshot = await avaliacoesRef.get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "id": doc.id, 
        "userId": data['userId'],
        "nomeUsuario": data['nomeUsuario'],
        "comentario": data['comentario'],
        "estrelas": data['estrelas'],
      };
    }).toList();
  }

  Future<void> excluirAvaliacao(String localId, String docId) async {
    final user = await _verificarUsuarioAutenticado();
    if (user == null) return;

    final avaliacoesRef = _obterReferenciasAvaliacoes(localId);
    await avaliacoesRef.doc(docId).delete();

    _calcularEMediaEstrelas(localId);
  }

  Future<bool> usuarioJaAvaliou(String localId, String userId) async {
    final avaliacoesRef = _obterReferenciasAvaliacoes(localId);
    final querySnapshot = await avaliacoesRef.where('userId', isEqualTo: userId).get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _calcularEMediaEstrelas(String localId) {
    _obterReferenciasAvaliacoes(localId).get().then((querySnapshot) {
      double mediaEstrelas = 0.0;
      if (querySnapshot.docs.isNotEmpty) {
        final totalEstrelas = querySnapshot.docs.fold<int>(
          0,
          (sum, doc) => sum + (doc.data()['estrelas'] as int),
        );
        mediaEstrelas = totalEstrelas / querySnapshot.docs.length;
      }

      _firestore.collection('locais').doc(localId).set({
        'mediaEstrelas': mediaEstrelas,
      }, SetOptions(merge: true));
    });
  }
}