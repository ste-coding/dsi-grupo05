import 'package:flutter/material.dart';
import '../models/itinerario_model.dart';
import '../views/itinerario_detail.page.dart'; // Importando a nova página

class ItineraryCard extends StatelessWidget {
  final ItinerarioModel itinerario;

  const ItineraryCard({Key? key, required this.itinerario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItinerarioDetailPage(itinerario: itinerario), // Passando o itinerário
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem com fallback
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                itinerario.imageUrl.isNotEmpty
                    ? itinerario.imageUrl
                    : 'https://via.placeholder.com/150',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            // Detalhes
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itinerario.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itinerario.observations.isNotEmpty
                        ? itinerario.observations
                        : 'Sem observações',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatDate(itinerario.startDate)} - ${_formatDate(itinerario.endDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.place, size: 16),
                          const SizedBox(width: 4),
                          Text('${itinerario.locais.length} locais'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
