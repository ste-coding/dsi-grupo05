import 'package:flutter/material.dart';
import '../models/local_model.dart';
import '../services/foursquare_service.dart';

class MenuController with ChangeNotifier {
  final FoursquareService _service = FoursquareService();
  List<LocalModel> _locais = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LocalModel> get locais => _locais;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLocais(String query, String location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _locais = await _service.fetchPlaces(query, location);
    } catch (e) {
      _errorMessage = 'Erro ao carregar locais: $e';
    }
    _isLoading = false;
    notifyListeners();
  }
}