import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/local_model.dart';
import '../models/local_detail_model.dart';

class FoursquareService {
  final String _apiKey = dotenv.env['FSQ_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.foursquare.com/v3/places/search';
  final String _detailsUrl = 'https://api.foursquare.com/v3/places';
  final Dio _dio = Dio();

  Future<List<LocalModel>> fetchPlaces(String query, String location) async {
  try {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'query': query,
        'near': location,
        'limit': 10,
        'fields': 'fsq_id,name,description,location,geocodes,rating,stats,photos,categories',
      },
      options: Options(headers: {'Authorization': _apiKey}),
    );

    if (response.statusCode == 200) {
      final List<LocalModel> places = [];
      final results = response.data['results'] as List;

      for (var place in results) {
        List<dynamic> photos = place['photos'] ?? [];
        if (photos.isNotEmpty) {
          place['photo_url'] = '${photos.first['prefix']}original${photos.first['suffix']}';
        } else {
          place['photo_url'] = '';
        }

        places.add(LocalModel.fromJson(place));
      }
      return places;
    } else {
      throw Exception('Erro ao buscar locais');
    }
  } catch (e) {
    throw Exception('Erro de conexão: $e');
  }
}


  

  Future<Map<String, dynamic>> fetchLocalDetails(String fsqId) async {
    try {
      final response = await _dio.get(
        '$_detailsUrl/$fsqId',
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


