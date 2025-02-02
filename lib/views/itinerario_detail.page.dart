import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/itinerario_model.dart';

class ItinerarioDetailPage extends StatelessWidget {
  final ItinerarioModel itinerario;

  ItinerarioDetailPage({required this.itinerario});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(itinerario.titulo),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Geral'),
              Tab(text: 'Roteiro'),
              Tab(text: 'Checklist'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGeralTab(),
            _buildRoteiroTab(),
            _buildChecklistTab(),
          ],
        ),
      ),
    );
  }

  // Aba Geral
  Widget _buildGeralTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem de capa
          Image.network(
            itinerario.imageUrl.isNotEmpty
                ? itinerario.imageUrl
                : 'https://via.placeholder.com/150',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16),
          Text(
            itinerario.titulo,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '${_formatDate(itinerario.startDate)} - ${_formatDate(itinerario.endDate)}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            itinerario.observations.isNotEmpty
                ? itinerario.observations
                : 'Sem observações.',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Aba Roteiro
  Widget _buildRoteiroTab() {
    return ListView.builder(
      itemCount: itinerario.locais.length,
      itemBuilder: (context, index) {
        final local = itinerario.locais[index];
        return ListTile(
          title: Text(local.localName ?? 'Local sem nome'),
          subtitle: Text('Visitado em: ${_formatDate(local.visitDate)}'),
          trailing: Text(local.comment),
        );
      },
    );
  }

  // Aba Checklist
  Widget _buildChecklistTab() {
    // Aqui você pode adicionar a lista de itens do checklist, por exemplo.
    return Center(
      child: Text('Aqui estará o Checklist'),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
