import './local_model.dart';

class LocalUserModel {
  final String id;
  final String nome;
  final String descricao;
  final String imagem;
  final String categoria;
  final String logradouro;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final double latitude;
  final double longitude;
  final String usuarioId;
  final DateTime dataCriacao;
  final double mediaEstrelas;
  final int totalAvaliacoes;

  LocalUserModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.imagem,
    required this.categoria,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.latitude,
    required this.longitude,
    required this.usuarioId,
    required this.dataCriacao,
    this.mediaEstrelas = 0.0,
    this.totalAvaliacoes = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nome": nome,
      "descricao": descricao,
      "imagem": imagem,
      "categoria": categoria,
      "logradouro": logradouro,
      "numero": numero,
      "bairro": bairro,
      "cidade": cidade,
      "estado": estado,
      "latitude": latitude,
      "longitude": longitude,
      "usuarioId": usuarioId,
      "dataCriacao": dataCriacao.toIso8601String(),
      "mediaEstrelas": mediaEstrelas,
      "totalAvaliacoes": totalAvaliacoes,
    };
  }

  factory LocalUserModel.fromJson(Map<String, dynamic> json) {
    return LocalUserModel(
      id: json['id'] ?? '', 
      nome: json['nome'] ?? '', 
      descricao: json['descricao'] ?? '', 
      imagem: json['imagem'] ?? '', 
      categoria: json['categoria'] ?? '', 
      logradouro: json['logradouro'] ?? '', 
      numero: json['numero'] ?? '', 
      bairro: json['bairro'] ?? '', 
      cidade: json['cidade'] ?? '', 
      estado: json['estado'] ?? '', 
      latitude: json['latitude']?.toDouble() ?? 0.0, 
      longitude: json['longitude']?.toDouble() ?? 0.0, 
      usuarioId: json['usuarioId'] ?? '',
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'])
          : DateTime.now(), 
      mediaEstrelas: json['mediaEstrelas']?.toDouble() ?? 0.0, 
      totalAvaliacoes: json['totalAvaliacoes'] ?? 0, 
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
      mediaEstrelas: mediaEstrelas,
      totalAvaliacoes: totalAvaliacoes,
    );
  }
}