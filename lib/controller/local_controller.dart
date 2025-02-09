import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/local_model.dart';
import '../models/local_response_model.dart';
import '../repositories/local_repository.dart';
import '../services/firestore/favoritos.service.dart';
import '../services/firestore/itinerarios.service.dart';
import '../models/itinerario_model.dart';

class LocalController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalRepository repository;
  final FavoritosService favoritosService;
  final ItinerariosService itinerariosService;

  bool _isLoading = false;
  bool _finishLoading = false;
  String? _errorMessage;
  final List<LocalModel> _locais = [];
  int _page = 0;

  bool get isLoading => _isLoading;
  bool get finishLoading => _finishLoading;
  String? get errorMessage => _errorMessage;
  List<LocalModel> get locais => _locais;

  LocalController(
      this.repository, this.favoritosService, this.itinerariosService);

  void resetLocais() {
    _locais.clear();
    _page = 0;
    _finishLoading = false;
    notifyListeners();
  }

  Future<void> addToFavoritos(String localId) async {
    try {
      await favoritosService.addFavorito(localId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao adicionar favorito: $e';
      notifyListeners();
    }
  }

  Future<void> removeFromFavoritos(String localId) async {
    try {
      await favoritosService.removeFavorito(localId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao remover favorito: $e';
      notifyListeners();
    }
  }

  Future<void> addToItinerario(Map<String, dynamic> itinerario) async {
    try {
      await itinerariosService.addItinerario(itinerario);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao adicionar ao itinerário: $e';
      notifyListeners();
    }
  }

  Future<void> fetchLocais(String query, String location) async {
    if (_isLoading || _finishLoading) return;

    _isLoading = true;
    notifyListeners();

    final result =
        await repository.fetchLocais(query, location, offset: _page * 20);

    result.fold(
      (error) {
        _errorMessage = error;
        _isLoading = false;
        notifyListeners();
      },
      (response) {
        if (response.locais.isEmpty) {
          _finishLoading = true;
        } else {
          _locais.addAll(response.locais);
          _page++;
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Função para buscar os itinerários do usuário
Future<List<ItinerarioModel>> getUserItinerarios() async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Usuário não autenticado");
      return [];
    }

    // Buscar itinerários do Firestore
    final snapshot = await _firestore
        .collection('viajantes')
        .doc(userId)
        .collection('itinerarios')
        .get();

    print("Snapshot de itinerários recuperado. Total de documentos: ${snapshot.docs.length}");

    if (snapshot.docs.isEmpty) {
      print("Nenhum itinerário encontrado.");
      return [];
    }

    List<ItinerarioModel> itinerarios = [];

    for (var doc in snapshot.docs) {
      var itinerarioData = doc.data();
      String itinerarioId = doc.id;

      // Buscar os locais do itinerário na subcoleção 'roteiro'
      var locaisSnapshot = await _firestore
          .collection('viajantes')
          .doc(userId)
          .collection('itinerarios')
          .doc(itinerarioId)
          .collection('roteiro')
          .get();

      List<ItinerarioItem> locais = locaisSnapshot.docs
          .map((localDoc) => ItinerarioItem.fromFirestore(localDoc.data()))
          .toList();

      // Agora, criamos o itinerário passando os locais encontrados
      itinerarios.add(ItinerarioModel.fromFirestore(itinerarioData, locais));
    }

    print("Itinerários carregados: ${itinerarios.length}");
    return itinerarios;
  } catch (e) {
    print('Erro ao buscar itinerários: $e');
    return [];
  }
}


  // Função para adicionar local ao itinerário
  Future<void> addLocalToRoteiro(
      String itinerarioId, LocalModel local, DateTime visitDate) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Usuário não autenticado");
      return;
    }

    final itinerarioDoc = await _firestore
        .collection('viajantes')
        .doc(userId)
        .collection('itinerarios')
        .doc(itinerarioId)
        .get();

    if (!itinerarioDoc.exists) {
      print("Erro: itinerário não encontrado para o ID: $itinerarioId");
      return;
    }

    final itinerarioItem = ItinerarioItem(
      localId: local.id,
      localName: local.nome,
      visitDate: visitDate, // Usando a data selecionada
      comment: 'Comentário opcional',
    );

    final localData = itinerarioItem.toFirestore();

    try {
      await _firestore
          .collection('viajantes')
          .doc(userId)
          .collection('itinerarios')
          .doc(itinerarioId)
          .collection('roteiro')
          .add(localData);

      print("Local adicionado ao roteiro com sucesso!");
      notifyListeners();
    } catch (e) {
      print("Erro ao adicionar local ao roteiro: $e");
    }
  }
}
