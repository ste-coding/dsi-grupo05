// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class AvaliacoesPage extends StatefulWidget {
  const AvaliacoesPage({super.key});

  @override
  State<AvaliacoesPage> createState() => _AvaliacoesPageState();
}

class _AvaliacoesPageState extends State<AvaliacoesPage> {
  List<Map<String, dynamic>> avaliacoes = [
    {
      "local": "Nome do lugar",
      "comentario": "Seu comentario",
      "estrelas": 4,
    },
  ];

  List<String> locaisVisitados = [
    "Restaurante Sabor Caseiro",
    "Cafeteria Aroma",
    "Parque das Flores",
    "Museu Histórico",
  ];

  TextEditingController comentarioController = TextEditingController();
  int estrelasSelecionadas = 0;
  String? localSelecionado;

  void adicionarOuEditarAvaliacao({int? index}) {
    if (comentarioController.text.isNotEmpty &&
        estrelasSelecionadas > 0 &&
        localSelecionado != null) {
      setState(() {
        if (index != null) {
          // Editar Avaliação Existente
          avaliacoes[index] = {
            "local": localSelecionado,
            "comentario": comentarioController.text,
            "estrelas": estrelasSelecionadas,
          };
        } else {
          // Adicionar Nova Avaliação
          avaliacoes.add({
            "local": localSelecionado,
            "comentario": comentarioController.text,
            "estrelas": estrelasSelecionadas,
          });
        }
        comentarioController.clear();
        estrelasSelecionadas = 0;
        localSelecionado = null;
      });
      Navigator.pop(context);
    }
  }

  void abrirDialogoAvaliacao({int? index}) {
    if (index != null) {
      final avaliacao = avaliacoes[index];
      comentarioController.text = avaliacao["comentario"];
      estrelasSelecionadas = avaliacao["estrelas"];
      localSelecionado = avaliacao["local"];
    } else {
      comentarioController.clear();
      estrelasSelecionadas = 0;
      localSelecionado = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Color(0xFF266B70), width: 2),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      index != null ? "Editar Avaliação" : "Nova Avaliação",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF266B70),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: locaisVisitados.contains(localSelecionado) ? localSelecionado : null,
                      items: locaisVisitados.toSet().map((local) {
                        return DropdownMenuItem(
                          value: local,
                          child: Text(local),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          localSelecionado = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Selecione um local",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: comentarioController,
                      decoration: InputDecoration(
                        labelText: "Comentário",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              estrelasSelecionadas = index + 1;
                            });
                          },
                          icon: Icon(
                            index < estrelasSelecionadas
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancelar"),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              adicionarOuEditarAvaliacao(index: index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF266B70),
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Salvar"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas avaliações'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/menu', (route) => false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
          
            const SizedBox(height: 8),
            Text(
              'Visualize, escreva ou edite uma avaliação.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: avaliacoes.length,
                itemBuilder: (context, index) {
                  final avaliacao = avaliacoes[index];
                  return Dismissible(
                    key: Key(avaliacao["comentario"]),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        avaliacoes.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Avaliação excluída')),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(avaliacao["local"]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(avaliacao["comentario"]),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < avaliacao["estrelas"]
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => abrirDialogoAvaliacao(index: index),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirDialogoAvaliacao(),
        backgroundColor: const Color(0xFF01A897),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}