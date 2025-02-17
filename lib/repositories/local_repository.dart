import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../models/local_model.dart';
import '../models/local_response_model.dart';
import '../models/local_detail_model.dart';
import '../services/foursquare_service.dart';

class LocalRepository {
  final FoursquareService _foursquareService;

  LocalRepository(this._foursquareService);

  Future<Either<String, LocalResponseModel>> fetchLocais(
      String query, String location,
      {int offset = 0}) async {
    try {
      final locais =
          await _foursquareService.fetchPlaces(query, location, offset: offset);

      return Right(LocalResponseModel(
        totalLocais: locais.length,
        totalPaginas: 5,
        paginaAtual: (offset ~/ locais.length) + 1,
        locais: locais,
      ));
    } catch (e) {
      return Left('Erro ao buscar locais: $e');
    }
  }

  Future<Either<String, LocalDetailModel>> fetchLocalDetalhes(
      String fsqId) async {
    try {
      final localDetalhesJson =
          await _foursquareService.fetchLocalDetails(fsqId);

      return Right(LocalDetailModel.fromJson(localDetalhesJson));
    } catch (e) {
      return Left('Erro ao buscar detalhes do local: $e');
    }
  }
}
