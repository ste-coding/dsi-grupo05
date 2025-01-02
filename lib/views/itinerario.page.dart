import 'package:flutter/material.dart';
import 'criar_itinerario.page.dart';

class ItinerarioPage extends StatefulWidget {
  const ItinerarioPage({super.key});

  @override
  State<ItinerarioPage> createState() => _ItinerarioPageState();
}

class _ItinerarioPageState extends State<ItinerarioPage> {
  final List<Map<String, String>> _itinerarios = [];

  void _adicionarOuAtualizarItinerario(Map<String, String> itinerario,
      {int? index}) {
    setState(() {
      if (index != null) {
        _itinerarios[index] = itinerario;
      } else {
        _itinerarios.add(itinerario);
      }
    });
  }

  // Função para excluir itinerário com confirmação
  Future<bool?> _confirmarExclusao(int index) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Itinerário'),
          content: Text('Você tem certeza que deseja excluir este itinerário?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancela a exclusão
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirma a exclusão
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFEAF1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Minha Viagem',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 8),
            Text(
              'Visualize ou edite seu itinerário',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Seu Itinerário',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _itinerarios.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum itinerário adicionado ainda.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _itinerarios.length,
                      itemBuilder: (context, index) {
                        final itinerario = _itinerarios[index];
                        return Dismissible(
                          key: Key(itinerario['titulo'] ?? ''),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            bool? confirmarExclusao =
                                await _confirmarExclusao(index);
                            if (confirmarExclusao == true) {
                              setState(() {
                                _itinerarios.removeAt(index);
                              });
                              return true;
                            }
                            return false;
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          child: Card(
                            child: ListTile(
                              title: Text(itinerario['titulo'] ?? ''),
                              subtitle: Text(
                                '${itinerario['horario']} - ${itinerario['localizacao']}',
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CriarItinerarioPage(
                                      onSalvarItinerario: (novoItinerario) {
                                        _adicionarOuAtualizarItinerario(
                                            novoItinerario,
                                            index:
                                                index); // Atualiza o itinerário
                                      },
                                      itinerarioExistente:
                                          itinerario, // Passa o itinerário para edição
                                    ),
                                  ),
                                );
                              },
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
              builder: (context) => CriarItinerarioPage(
                onSalvarItinerario: _adicionarOuAtualizarItinerario,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF266B70),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
