class LocalModel {
  final String id;
  final String nome;
  final String descricao;
  final String imagem;
  final String categoria;
  final String cidade;
  final String estado;
  final double latitude;
  final double longitude;
  double mediaEstrelas; // Tornar mutável para permitir atualização
  final int totalAvaliacoes;

  LocalModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.imagem,
    required this.categoria,
    required this.cidade,
    required this.estado,
    required this.latitude,
    required this.longitude,
    this.mediaEstrelas = 0.0, // Inicializa com 0
    required this.totalAvaliacoes,
  });

  factory LocalModel.fromJson(Map<String, dynamic> json) {
    return LocalModel(
      id: json['fsq_id'] ?? '',
      nome: json['name'] ?? 'Nome não disponível',
      descricao: json['description'] ?? 'Sem descrição',
      imagem: json['photos']?.isNotEmpty == true 
          ? json['photos'][0]['prefix'] + 'original' + json['photos'][0]['suffix']
          : 'https://via.placeholder.com/150',
      categoria: json['categories']?.isNotEmpty == true 
          ? json['categories'][0]['name'] 
          : 'Sem categoria',
      cidade: json['location']?['locality'] ?? 'Cidade não disponível',
      estado: json['location']?['region'] ?? 'Estado não disponível',
      latitude: json['geocodes']?['main']?['latitude']?.toDouble() ?? 0.0,
      longitude: json['geocodes']?['main']?['longitude']?.toDouble() ?? 0.0,
      mediaEstrelas: (json['rating'] ?? 0).toDouble(),
      totalAvaliacoes: json['stats']?['total_ratings'] ?? 0,
    );
  }

  factory LocalModel.fromFirestore(Map<String, dynamic> json) {
    return LocalModel(
      id: json['id'] ?? '',
      nome: json['nome'] ?? 'Nome não disponível',
      descricao: json['descricao'] ?? 'Sem descrição',
      imagem: json['imagem'] ?? 'https://via.placeholder.com/150',
      categoria: json['categoria'] ?? 'Sem categoria',
      cidade: json['cidade'] ?? 'Cidade não disponível',
      estado: json['estado'] ?? 'Estado não disponível',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      mediaEstrelas: (json['mediaEstrelas'] ?? 0).toDouble(),
      totalAvaliacoes: json['totalAvaliacoes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'imagem': imagem,
      'categoria': categoria,
      'cidade': cidade,
      'estado': estado,
      'latitude': latitude,
      'longitude': longitude,
      'mediaEstrelas': mediaEstrelas,
      'totalAvaliacoes': totalAvaliacoes,
    };
  }
}