import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';  // Para usar Left e Right
import '../models/local_model.dart';
import '../models/local_response_model.dart';
import '../repositories/local_repository.dart';

class LocalController with ChangeNotifier {
  final LocalRepository repository;

  bool _isLoading = false;
  List<LocalModel> _locais = [];

  bool get isLoading => _isLoading;
  List<LocalModel> get locais => _locais;

  LocalController(this.repository);

  Future<void> fetchLocais(String query, String location) async {
    _isLoading = true;
    notifyListeners();

    final result = await repository.fetchLocais(query, location);

    result.fold(
      (error) {
        // Exibir erro
        print("Erro ao carregar locais: $error");
        _isLoading = false;
        notifyListeners();
      },
      (response) {
        _locais = response.locais; // Armazenando a lista de locais
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
