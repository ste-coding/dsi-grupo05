import 'local_model.dart';

class LocalDetailModel {
  final LocalModel localModel;
  final String email;
  final List<String> horas;
  final String menu;
  final List<String> dicas;
  final String endereco;
  final String timezone;
  final List<String> fotos;

  LocalDetailModel({
    required this.localModel,
    required this.email,
    required this.horas,
    required this.menu,
    required this.dicas,
    required this.endereco,
    required this.timezone,
    required this.fotos,
  });

  factory LocalDetailModel.fromJson(Map<String, dynamic> json) {
    List<String> fotosList = [];
    if (json['photos'] != null) {
      for (var photo in json['photos']) {
        String photoUrl = photo['prefix'] + 'original' + photo['suffix'];
        fotosList.add(photoUrl);
      }
    }

    List<String> horasList = [];
    if (json['hours'] != null) {
      for (var hour in json['hours']['periods']) {
        String horaStr = 'Dia: ${hour['day']}, Horário: ${hour['open']} - ${hour['close']}';
        horasList.add(horaStr);
      }
    }

    List<String> dicasList = [];
    if (json['tips'] != null) {
      for (var tip in json['tips']) {
        dicasList.add(tip['text'] ?? 'Sem dica');
      }
    }

    return LocalDetailModel(
      localModel: LocalModel.fromJson(json),
      email: json['email'] ?? 'Email não disponível',
      horas: horasList,
      menu: json['menu'] ?? 'Menu não disponível',
      dicas: dicasList,
      endereco: json['location']['formatted_address'] ?? 'Endereço não disponível',
      timezone: json['timezone'] ?? 'Fuso horário não disponível',
      fotos: fotosList,
    );
  }
}
