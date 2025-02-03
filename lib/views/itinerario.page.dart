import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/itinerario_model.dart';
import 'package:flutter_application_1/services/firestore/itinerarios.service.dart';
import 'package:flutter_application_1/widgets/itinerario_card.dart';
import 'package:flutter_application_1/views/explore.page.dart';
import '../controller/local_controller.dart';
import '../models/local_model.dart';
import 'package:intl/intl.dart';

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
                  builder: (context) => ExplorePage(
                    onSelectedLocal: (local) {
                      final controller = Provider.of<LocalController>(context, listen: false);
                      controller.addToItinerario({
                        'localId': local.id,
                        'localName': local.nome,
                        'visitDate': Timestamp.now(), // Data de visita exemplo
                        'comment': '',
                      });
                    },
                  ),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.travel_explore, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum itinerário encontrado.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final itinerarios = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ItinerarioModel.fromFirestore(data);
          }).toList();

          return ListView.builder(
            itemCount: itinerarios.length,
            itemBuilder: (context, index) {
              final itinerario = itinerarios[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ItineraryCard(itinerario: itinerario),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExplorePage(
                onSelectedLocal: (local) {
                  final controller = Provider.of<LocalController>(context, listen: false);
                  controller.addToItinerario({
                    'localId': local.id,
                    'localName': local.nome,
                    'visitDate': Timestamp.now(),
                    'comment': '',
                  });
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
