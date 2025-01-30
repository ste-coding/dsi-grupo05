import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/viajante_model.dart';

class ViajanteService {
  final DocumentReference viajanteRef;

  ViajanteService(String userId) : viajanteRef = FirebaseFirestore.instance.collection('viajantes').doc(userId);

  Future<void> updateBio(String novaBio) async {
    try {
      await viajanteRef.update({
        'bio': novaBio,
      });
    } catch (e) {
      print("Erro ao atualizar bio: $e");
      rethrow;
    }
  }

  Future<ViajanteModel?> getViajante() async {
    try {
      DocumentSnapshot docSnapshot = await viajanteRef.get();
      if (docSnapshot.exists) {
        return ViajanteModel.fromFirestore(docSnapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print("Erro ao recuperar dados do viajante: $e");
      rethrow;
    }
  }
}
