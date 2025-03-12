import 'package:flutter/material.dart';
import '../models/avaliacao_model.dart';

class AvaliacoesWidget extends StatelessWidget {
  final List<AvaliacaoModel> avaliacoes;
  final String nomeUsuario;
  final Function(String id) onDelete;

  const AvaliacoesWidget({
    super.key,
    required this.avaliacoes,
    required this.nomeUsuario,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avaliações',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (avaliacoes.isEmpty)
          const Text(
            'Nenhuma avaliação ainda. Seja o primeiro a avaliar.',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: avaliacoes.length,
            itemBuilder: (context, index) {
              final avaliacao = avaliacoes[index];
              return Dismissible(
                key: Key(avaliacao.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (nomeUsuario != avaliacao.userName) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Você não pode excluir esta avaliação.')),
                    );
                    return false;
                  }
                  return true;
                },
                onDismissed: (direction) => onDelete(avaliacao.id),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      avaliacao.userName,
                      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(avaliacao.comment, style: const TextStyle(fontFamily: 'Poppins')),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < avaliacao.rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}