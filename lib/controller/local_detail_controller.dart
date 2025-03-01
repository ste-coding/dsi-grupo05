import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../models/local_detail_model.dart';
import '../repositories/local_repository.dart';

class LocalDetailController with ChangeNotifier {
  final LocalRepository _localRepository;
  LocalDetailModel? _localDetail;
  String _errorMessage = '';

  LocalDetailModel? get localDetail => _localDetail;
  String get errorMessage => _errorMessage;

  LocalDetailController(this._localRepository);

  Future<void> fetchLocalDetail(String fsqId) async {
    final result = await _localRepository.fetchLocalDetalhes(fsqId);
    result.fold(
      (error) {
        _errorMessage = error;
        notifyListeners();
      },
      (localDetailModel) {
        _localDetail = localDetailModel;
        notifyListeners();
      },
    );
  }
}
