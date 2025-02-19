import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvaliacoesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtém a referência da coleção de avaliações para um local específico
  CollectionReference<Map<String, dynamic>> _obterReferenciasAvaliacoes(String localId) {
    return _firestore.collection('locais').doc(localId).collection('avaliacoes');
  }

  /// Verifica se o usuário está autenticado e retorna o usuário atual
  Future<User?> _verificarUsuarioAutenticado() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }
    return user;
  }

  /// Salva ou atualiza uma avaliação no Firestore
  Future<void> salvarAvaliacao(String localId, Map<String, dynamic> avaliacao, {String? docId}) async {
    final user = await _verificarUsuarioAutenticado();
    if (user == null) return;

    final avaliacoesRef = _obterReferenciasAvaliacoes(localId);
    final data = {
      'userId': user.uid,
      'nomeUsuario': avaliacao['local'],
      'comentario': avaliacao['comentario'],
      'estrelas': avaliacao['estrelas'],
      'data': FieldValue.serverTimestamp(),
    };

    if (docId != null) {
      await avaliacoesRef.doc(docId).update(data);
    } else {
      await avaliacoesRef.add(data);
    }
  }

  /// Carrega as avaliações de um local
  Future<List<Map<String, dynamic>>> carregarAvaliacoes(String localId) async {
    final avaliacoesRef = _obterReferenciasAvaliacoes(localId);
    final querySnapshot = await avaliacoesRef.get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "local": data['nomeUsuario'],
        "comentario": data['comentario'],
        "estrelas": data['estrelas'],
      };
    }).toList();
  }

  /// Exclui uma avaliação com base no comentário e no nome do usuário
  Future<void> excluirAvaliacao(String localId, String comentario, String nomeUsuario) async {
    final user = await _verificarUsuarioAutenticado();
    if (user == null) return;

    final avaliacoesRef = _obterReferenciasAvaliacoes(localId);
    final querySnapshot = await avaliacoesRef
        .where('comentario', isEqualTo: comentario)
        .where('nomeUsuario', isEqualTo: nomeUsuario)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.delete();
    }
  }
}
