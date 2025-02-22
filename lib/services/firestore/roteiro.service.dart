import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/roteiro_model.dart';

class RoteiroService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String itinerarioCollection = 'roteiros';
  Future<void> saveActivities(String roteiroId, DateTime date,
      List<Map<String, dynamic>> activities) async {
    try {
      final atividadesCollection = _db
          .collection(itinerarioCollection)
          .doc(roteiroId)
          .collection('atividades');

      for (var activity in activities) {
        String timeStr = activity['time']; // Hora já está como string formatada

        await atividadesCollection.add({
          'name': activity['name'],
          'time': timeStr, // Salva sempre como string
          'date': Timestamp.fromDate(date),
        });
      }
    } catch (e) {
      throw Exception("Erro ao salvar as atividades no banco: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getActivities(String roteiroId) async {
    try {
      final atividadesCollection = _db
          .collection(itinerarioCollection)
          .doc(roteiroId)
          .collection('atividades');

      final snapshot = await atividadesCollection.get();
      return snapshot.docs.map((doc) {
        DateTime activityDate = (doc['date'] as Timestamp).toDate();

        String timeString = doc['time']; // Hora está como string

        // Converte para TimeOfDay
        TimeOfDay activityTime = RoteiroModel.stringToTimeOfDay(timeString);

        return {
          'name': doc['name'],
          'time': activityTime,
          'date': activityDate.toString(),
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      print("Erro ao carregar as atividades: $e");
      throw Exception("Erro ao carregar as atividades: $e");
    }
  }

  Future<void> deleteActivity(String roteiroId, String activityId) async {
    try {
      await _db
          .collection(itinerarioCollection)
          .doc(roteiroId)
          .collection('atividades')
          .doc(activityId)
          .delete();
    } catch (e) {
      throw Exception("Erro ao excluir a atividade: $e");
    }
  }

  Future<void> updateActivity(String roteiroId, String activityId,
      Map<String, dynamic> updatedActivity) async {
    try {
      await _db
          .collection(itinerarioCollection)
          .doc(roteiroId)
          .collection('atividades')
          .doc(activityId)
          .update(updatedActivity);
    } catch (e) {
      throw Exception("Erro ao atualizar a atividade: $e");
    }
  }
}
