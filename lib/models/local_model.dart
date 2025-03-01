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
  final double mediaEstrelas;
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
    required this.mediaEstrelas,
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
}
