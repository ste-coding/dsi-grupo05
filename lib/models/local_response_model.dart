import 'local_model.dart';

class LocalResponseModel {
  final int totalLocais;
  final int totalPaginas;
  final int paginaAtual;
  final List<LocalModel> locais;

  LocalResponseModel({
    required this.totalLocais,
    required this.totalPaginas,
    required this.paginaAtual,
    required this.locais,
  });

  factory LocalResponseModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> locaisJson = json['results'] ?? [];
    
    return LocalResponseModel(
      totalLocais: json['count'] ?? 0,
      totalPaginas: json['total_pages'] ?? 0,
      paginaAtual: json['current_page'] ?? 1,
      locais: locaisJson.map((localJson) => LocalModel.fromJson(localJson)).toList(),
    );
  }
}
