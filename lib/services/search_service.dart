import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/local_model.dart';

class SearchService {
  final String _baseUrl = 'http://localhost:3000'; // URL do backend

  Future<List<LocalModel>> fetchPlaces(String query, String ll, int radius) async {
    final url = Uri.parse('$_baseUrl/search-places?query=$query&ll=$ll&radius=$radius');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        return results.isNotEmpty
            ? results.map((item) => LocalModel.fromJson(item)).toList()
            : [];
      } else {
        throw Exception('Erro ao carregar os locais: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
