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

  void abrirTelaAvaliacao({int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvaliacaoFormPage(
          index: index,
          avaliacao: index != null ? avaliacoes[index] : null,
          locaisVisitados: locaisVisitados,
          onSave: (avaliacao) {
            setState(() {
              if (index != null) {
                avaliacoes[index] = avaliacao;
              } else {
                avaliacoes.add(avaliacao);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Avaliações',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
            Text(
              'Visualize, escreva ou edite uma avaliação.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey[600],
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        avaliacoes.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Avaliação excluída',
                                style: TextStyle(fontFamily: 'Poppins'))),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(avaliacao["local"],
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(avaliacao["comentario"],
                                style: const TextStyle(fontFamily: 'Poppins')),
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
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => abrirTelaAvaliacao(index: index),
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
        onPressed: () => abrirTelaAvaliacao(),
        backgroundColor: const Color(0xFF01A897),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AvaliacaoFormPage extends StatefulWidget {
  final int? index;
  final Map<String, dynamic>? avaliacao;
  final List<String> locaisVisitados;
  final Function(Map<String, dynamic>) onSave;

  const AvaliacaoFormPage({
    Key? key,
    this.index,
    this.avaliacao,
    required this.locaisVisitados,
    required this.onSave,
  }) : super(key: key);

  @override
  _AvaliacaoFormPageState createState() => _AvaliacaoFormPageState();
}

class _AvaliacaoFormPageState extends State<AvaliacaoFormPage> {
  TextEditingController comentarioController = TextEditingController();
  int estrelasSelecionadas = 0;
  String? localSelecionado;

  @override
  void initState() {
    super.initState();
    if (widget.avaliacao != null) {
      comentarioController.text = widget.avaliacao!["comentario"];
      estrelasSelecionadas = widget.avaliacao!["estrelas"];
      localSelecionado = widget.avaliacao!["local"];
    }
  }

  void salvarAvaliacao() {
    if (comentarioController.text.isNotEmpty &&
        estrelasSelecionadas > 0 &&
        localSelecionado != null) {
      widget.onSave({
        "local": localSelecionado,
        "comentario": comentarioController.text,
        "estrelas": estrelasSelecionadas,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.index != null ? "Editar Avaliação" : "Nova Avaliação",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: widget.locaisVisitados.contains(localSelecionado)
                  ? localSelecionado
                  : null,
              items: widget.locaisVisitados.toSet().map((local) {
                return DropdownMenuItem(
                  value: local,
                  child: Text(local, style: const TextStyle(fontFamily: 'Poppins')),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  localSelecionado = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "Selecione um local",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: comentarioController,
              decoration: const InputDecoration(
                labelText: "Comentário",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
                border: OutlineInputBorder(),
              ),
              style:
