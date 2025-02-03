import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
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

  Future<List<ItinerarioModel>> getUserItinerarios() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print("Usuário não autenticado");
        return [];
      }

      final snapshot = await _firestore
          .collection('itinerarios')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        print("Nenhum itinerário encontrado.");
        return [];
      }

      List<ItinerarioModel> itinerarios = snapshot.docs
          .map((doc) => ItinerarioModel.fromFirestore(doc.data()))
          .toList();

      print("Itinerários carregados: ${itinerarios.length}");
      return itinerarios;
    } catch (e) {
      print('Erro ao buscar itinerários: $e');
      return [];
    }
  }

  Future<void> addLocalToRoteiro(String itinerarioId, LocalModel local) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Usuário não autenticado");
      return;
    }

    final itinerarioItem = ItinerarioItem(
      localId: local.id,
      localName: local.nome,
      visitDate: DateTime.now(),
      comment: 'Comentário opcional',
    );

    final localData = itinerarioItem.toFirestore();

    try {
      await itinerariosService.addLocalToRoteiro(itinerarioId, localData);
      print("Local adicionado ao roteiro com sucesso!");
      notifyListeners();
    } catch (e) {
      print("Erro ao adicionar local ao roteiro: $e");
    }
  }
}
