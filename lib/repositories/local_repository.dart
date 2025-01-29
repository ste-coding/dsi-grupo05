// lib/repositories/local_repository.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../models/local_model.dart';
import '../models/local_response_model.dart';
import '../models/local_detail_model.dart';
import '../services/foursquare_service.dart';

class LocalRepository {
  final FoursquareService _foursquareService;

  LocalRepository(this._foursquareService);

  // Método para buscar uma lista de locais
  Future<Either<String, LocalResponseModel>> fetchLocais(String query, String location) async {
    try {
      // Chama o serviço para obter os locais
      final locais = await _foursquareService.fetchPlaces(query, location);

      // Retorna um sucesso com a resposta transformada em LocalResponseModel
      return Right(LocalResponseModel(
        totalLocais: locais.length,
        totalPaginas: 1,  // Ajuste conforme necessário
        paginaAtual: 1,   // Ajuste conforme necessário
        locais: locais,
      ));
    } catch (e) {
      // Retorna um erro se algo deu errado
      return Left('Erro ao buscar locais: $e');
    }
  }

  // Método para buscar os detalhes de um local específico
  Future<Either<String, LocalDetailModel>> fetchLocalDetalhes(String fsqId) async {
    try {
      // Chama o serviço para obter detalhes do local
      final localDetalhesJson = await _foursquareService.fetchLocalDetails(fsqId);

      // Retorna um sucesso com o modelo de detalhes do local
      return Right(LocalDetailModel.fromJson(localDetalhesJson));
    } catch (e) {
      // Retorna um erro se algo deu errado
      return Left('Erro ao buscar detalhes do local: $e');
    }
  }
}
