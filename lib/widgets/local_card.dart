import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/local_model.dart';
import 'package:flutter_application_1/services/firestore/favoritos.service.dart';
import 'package:flutter_application_1/views/local_details.page.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class LocalCard extends StatefulWidget {
  final LocalModel local;
  final FavoritosService favoritosService;

  const LocalCard({
    super.key,
    required this.local,
    required this.favoritosService,
  });

  @override
  State<LocalCard> createState() => _LocalCardState();
}

class _LocalCardState extends State<LocalCard> {
  bool isFavorito = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorito();
    widget.favoritosService.addListener(_favoritosListener);
  }

  @override
  void dispose() {
    widget.favoritosService.removeListener(_favoritosListener);
    super.dispose();
  }

  void _favoritosListener() {
    _checkIfFavorito();
  }

  Future<void> _checkIfFavorito() async {
    final favorito =
        await widget.favoritosService.checkIfFavoritoExists(widget.local.id);
    if (mounted) {
      setState(() {
        isFavorito = favorito;
      });
    }
  }

  Future<void> _toggleFavorito() async {
    try {
      if (isFavorito) {
        await widget.favoritosService.removeFavorito(widget.local.id);
      } else {
        await widget.favoritosService
            .addFavorito(widget.local); // ✅ Agora passamos o LocalModel inteiro
      }

      if (mounted) {
        setState(() {
          isFavorito = !isFavorito;
        });
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar favorito: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocalDetailsPage(local: widget.local),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: widget.local.imagem.isNotEmpty
                      ? (widget.local.imagem.startsWith('http')
                          ? Image.network(
                              widget.local.imagem,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey[700]);
                              },
                            )
                          : Image.memory(
                              base64Decode(widget.local.imagem),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey[700]);
                              },
                            ))
                      : Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.image,
                              size: 50, color: Colors.grey[700]),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorito,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: isFavorito ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.local.nome,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.local.mediaEstrelas.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${widget.local.cidade}, ${widget.local.estado}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  if (widget.local.totalAvaliacoes > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '+${widget.local.totalAvaliacoes}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
