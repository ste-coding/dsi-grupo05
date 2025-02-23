import 'package:flutter/material.dart';

class RoteiroModel {
  String id;
  String titulo;
  String descricao;
  String data; // Data como string
  String time; // Horário como string

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
      time: json['time'] ?? '00:00', // Hora como string
    );
  }

  // Converter para JSON (objeto para Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'data': data, // Mantém a data como string
      'time': time, // Mantém a hora como string
    };
  }
}
