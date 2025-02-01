import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../models/local_model.dart';
import '../models/local_response_model.dart';
import '../repositories/local_repository.dart';
import '../services/firestore/favoritos.service.dart';
import '../services/firestore/itinerarios.service.dart';

class LocalController with ChangeNotifier {
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

  LocalController(this.repository, this.favoritosService, this.itinerariosService);

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

    final result = await repository.fetchLocais(query, location, offset: _page * 20);

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
}
