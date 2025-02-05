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

  void editarAvaliacao(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EscolherLocalEAvaliarPage(
          avaliacao: avaliacoes[index],
          locaisVisitados: locaisVisitados,
          onSalvar: (local, comentario, estrelas) {
            setState(() {
              avaliacoes[index] = {
                "local": local,
                "comentario": comentario,
                "estrelas": estrelas,
              };
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFEAF1),
      appBar: AppBar(
        title: const Text(
          'Avaliações',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                          onPressed: () => editarAvaliacao(index),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EscolherLocalEAvaliarPage(
                locaisVisitados: locaisVisitados,
                onSalvar: (local, comentario, estrelas) {
                  setState(() {
                    avaliacoes.add({
                      "local": local,
                      "comentario": comentario,
                      "estrelas": estrelas,
                    });
                  });
                },
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF266B70),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class EscolherLocalEAvaliarPage extends StatefulWidget {
  final List<String> locaisVisitados;
  final Function(String, String, int) onSalvar;
  final Map<String, dynamic>? avaliacao;

  const EscolherLocalEAvaliarPage({
    super.key,
    required this.locaisVisitados,
    required this.onSalvar,
    this.avaliacao,
  });

  @override
  _EscolherLocalEAvaliarPageState createState() =>
      _EscolherLocalEAvaliarPageState();
}

class _EscolherLocalEAvaliarPageState extends State<EscolherLocalEAvaliarPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFEAF1),
      appBar: AppBar(
        title: Text(
          widget.avaliacao != null ? "Editar Avaliação" : "Nova Avaliação",
          style: const TextStyle(
            color: Colors.black, // Cor do texto
            fontFamily: 'Poppins', // Fonte personalizada
            fontSize: 28, // Tamanho da fonte
            fontWeight: FontWeight.bold, // Peso da fonte
          ),
        ),
        backgroundColor: const Color(0xFFDFEAF1), // Cor do fundo da AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: DropdownButtonFormField<String>(
                value: localSelecionado,
                items: widget.locaisVisitados.map((local) {
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
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: comentarioController,
                decoration: InputDecoration(
                  labelText: "Comentário",
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                if (comentarioController.text.isNotEmpty &&
                    estrelasSelecionadas > 0 &&
                    localSelecionado != null) {
                  widget.onSalvar(localSelecionado!, comentarioController.text,
                      estrelasSelecionadas);
                  Navigator.pop(context);
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: const Color(0xFF266B70),
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 24), // Aumenta o tamanho do botão
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Salvar',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22, // Aumenta o tamanho da fonte
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
