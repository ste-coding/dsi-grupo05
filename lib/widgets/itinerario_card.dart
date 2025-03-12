import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/itinerario_model.dart';
import '../views/itinerario_detalhes.page.dart';

class ItineraryCard extends StatelessWidget {
  final ItinerarioModel itinerario;

  const ItineraryCard({super.key, required this.itinerario});

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
              builder: (context) =>
                  ItinerarioDetalhesPage(itinerario: itinerario),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 180, // Limita a altura da imagem
                child: itinerario.imageUrl != null &&
                        itinerario.imageUrl!.isNotEmpty
                    ? Image.memory(
                        base64Decode(itinerario.imageUrl!),
                        fit: BoxFit.cover,
                        width: double.infinity, // Para garantir que a imagem ocupe toda a largura
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child:
                              const Icon(Icons.image_not_supported, size: 50),
                        ),
                      )
                    : Image.asset(
                        'assets/images/placeholder_image.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itinerario.titulo,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itinerario.observations.isNotEmpty
                        ? itinerario.observations
                        : 'Sem observações',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatDate(itinerario.startDate)} - ${_formatDate(itinerario.endDate)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
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
