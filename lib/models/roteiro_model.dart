import 'package:flutter/material.dart';

class RoteiroModel {
  String id;
  String titulo;
  String descricao;
  String data;
  TimeOfDay time; // Agora armazenado corretamente

  RoteiroModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.time,
  });

  // Converter de JSON (Firestore para objeto)
  factory RoteiroModel.fromJson(Map<String, dynamic> json) {
    return RoteiroModel(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      data: json['data'] ?? '',
      time: stringToTimeOfDay(json['time'] ?? '00:00'), // Conversão correta
    );
  }

  // Converter para JSON (objeto para Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'data': data,
      'time': timeOfDayToString(time), // Salvar como string
    };
  }

  static TimeOfDay stringToTimeOfDay(String timeString) {
    List<String> timeParts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }

  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
