import './local_model.dart';

class LocalUserModel {
  final String id;
  final String nome;
  final String descricao;
  final String imagem;
  final String categoria;
  final String cidade;
  final String estado;
  final double latitude;
  final double longitude;
  final String usuarioId;
  final DateTime dataCriacao;

  LocalUserModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.imagem,
    required this.categoria,
    required this.cidade,
    required this.estado,
    required this.latitude,
    required this.longitude,
    required this.usuarioId,
    required this.dataCriacao,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nome": nome,
      "descricao": descricao,
      "imagem": imagem,
      "categoria": categoria,
      "cidade": cidade,
      "estado": estado,
      "latitude": latitude,
      "longitude": longitude,
      "usuarioId": usuarioId,
      "dataCriacao": dataCriacao.toIso8601String(),
    };
  }

  factory LocalUserModel.fromJson(Map<String, dynamic> json) {
    return LocalUserModel(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      imagem: json['imagem'],
      categoria: json['categoria'],
      cidade: json['cidade'],
      estado: json['estado'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      usuarioId: json['usuarioId'],
      dataCriacao: DateTime.parse(json['dataCriacao']),
    );
  }

  /// Método para converter um `LocalUserModel` para `LocalModel`
  LocalModel toLocalModel() {
    return LocalModel(
      id: id,
      nome: nome,
      descricao: descricao,
      imagem: imagem,
      categoria: categoria,
      cidade: cidade,
      estado: estado,
      latitude: latitude,
      longitude: longitude,
      mediaEstrelas: 0.0, // Valor padrão
      totalAvaliacoes: 0, // Valor padrão
    );
  }
}