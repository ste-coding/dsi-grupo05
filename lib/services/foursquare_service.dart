import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/local_model.dart';
import '../models/local_detail_model.dart';

class FoursquareService {
  final String _apiKey = dotenv.env['FSQ_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.foursquare.com/v3/places/search';
  final String _detailsUrl = 'https://api.foursquare.com/v3/places';  // Nova URL para detalhes de locais
  final Dio _dio = Dio();

  // Método para buscar locais
  Future<List<LocalModel>> fetchPlaces(String query, String location) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'query': query,
          'near': location,
          'limit': 10,
        },
        options: Options(
          headers: {
            'Authorization': _apiKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['results'] as List)
            .map((json) => LocalModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Erro ao buscar locais');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Método para buscar os detalhes de um local específico
  Future<Map<String, dynamic>> fetchLocalDetails(String fsqId) async {
    try {
      final response = await _dio.get(
        '$_detailsUrl/$fsqId',  // Usando o ID do local na URL para buscar os detalhes
        options: Options(
          headers: {
            'Authorization': _apiKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erro ao buscar detalhes do local');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
