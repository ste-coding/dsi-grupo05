import 'package:flutter/material.dart';
import '../models/local_model.dart';
import '../views/local_details.page.dart';

class LocalCard extends StatelessWidget {
  final LocalModel local;

  const LocalCard({super.key, required this.local});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocalDetailsPage(local: local),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: local.imagem.isNotEmpty
                      ? Image.network(
                          local.imagem,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 50, color: Colors.grey[700]),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.bookmark_border, size: 20),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        local.nome,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            local.mediaEstrelas.toStringAsFixed(1),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${local.cidade}, ${local.estado}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (local.totalAvaliacoes > 0) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Padding(
                            padding: EdgeInsets.only(right: 2),
                            child: CircleAvatar(
                              radius: 8,
                              backgroundImage: NetworkImage('https://via.placeholder.com/16'),
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '+${local.totalAvaliacoes}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

