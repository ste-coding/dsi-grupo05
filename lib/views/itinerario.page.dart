import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/itinerario_model.dart';
import 'package:flutter_application_1/services/firestore/itinerarios.service.dart';
import 'package:flutter_application_1/widgets/itinerario_card.dart';
import 'package:flutter_application_1/views/criar_itinerario.page.dart';

class ItinerariosPage extends StatelessWidget {
  final String userId;

  ItinerariosPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    final itinerariosService = ItinerariosService(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateItinerarioPage(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itinerariosService.getItinerariosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum itinerário encontrado.'));
          }

          final itinerarios = snapshot.data!.docs.map((doc) {
            return ItinerarioModel.fromFirestore(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: itinerarios.length,
            itemBuilder: (context, index) {
              final itinerario = itinerarios[index];
              return ItineraryCard(itinerario: itinerario);
            },
          );
        },
      ),
    );
  }
}
