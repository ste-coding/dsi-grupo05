import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../models/local_model.dart';
import '../models/local_response_model.dart';
import '../repositories/local_repository.dart';

class LocalController with ChangeNotifier {
  final LocalRepository repository;
  bool _isLoading = false;
  String? _errorMessage;
  List<LocalModel> _locais = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<LocalModel> get locais => _locais;

  LocalController(this.repository);

  Future<void> fetchLocais(String query, String location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.fetchLocais(query, location);

    result.fold(
      (error) {
        _errorMessage = error;
        _isLoading = false;
        notifyListeners();
      },
      (response) {
        _locais = response.locais;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
