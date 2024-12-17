import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class PontosTuristicosService {
  final CollectionReference pontosTuristicos =
      FirebaseFirestore.instance.collection('pontos_turisticos');

  Stream<QuerySnapshot> getPontosTuristicos() {
    return pontosTuristicos.snapshots();
  }

  Future<void> addPointsFromLocalCsv() async {
    try {
      final csvString = await rootBundle.loadString('assets/csv/pontos_turisticos.csv');
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

      for (var row in rows) {
        final location = jsonDecode(row[5]);

        final point = {
          'name': row[0],
          'address': row[1],
          'city': row[2],
          'state': row[3],
          'stars': row[4],
          'location': {
            'latitude': location['latitude'],
            'longitude': location['longitude']
          },
        };

        await pontosTuristicos.add(point);
      }
    } catch (e) {
      print('Erro ao carregar CSV local: $e');
    }
  }
}
