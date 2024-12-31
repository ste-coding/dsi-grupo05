// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore.dart';


class ItinerarioPage extends StatefulWidget {
  const ItinerarioPage({super.key});

  @override
  State<ItinerarioPage> createState() => _ItinerarioPageState();
}

class _ItinerarioPageState extends State<ItinerarioPage> {
  final FirestoreService firestoreService = FirestoreService();
  final List<Map<String, String>> _atividades = [];
  final _tituloController = TextEditingController();
  final _horarioController = TextEditingController();
  final _localizacaoController = TextEditingController();

  int? _indiceEdicao;

  void _adicionarAtividade() {
    if (_tituloController.text.isNotEmpty &&
        _horarioController.text.isNotEmpty &&
        _localizacaoController.text.isNotEmpty) {
      setState(() {
        if (_indiceEdicao == null) {
          _atividades.add({
            'titulo': _tituloController.text,
            'horario': _horarioController.text,
            'localizacao': _localizacaoController.text,
          });
        } else {
          _atividades[_indiceEdicao!] = {
            'titulo': _tituloController.text,
            'horario': _horarioController.text,
            'localizacao': _localizacaoController.text,
          };
          _indiceEdicao = null;
        }
        _tituloController.clear();
        _horarioController.clear();
        _localizacaoController.clear();
      });
    }
  }

  void _editarAtividade(int index) {
    setState(() {
      _indiceEdicao = index;
      _tituloController.text = _atividades[index]['titulo']!;
      _horarioController.text = _atividades[index]['horario']!;
      _localizacaoController.text = _atividades[index]['localizacao']!;
    });
  }

  void _excluirAtividade(int index) {
    setState(() {
      _atividades.removeAt(index);
    });
  }

  Future<void> _confirmarExclusao(int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir esta atividade?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Não excluir
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Excluir
            },
            child: Text('Excluir'),
          ),
        ],
      ),
    );

    if (result == true) {
      _excluirAtividade(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              'Minha Viagem',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Visualize ou edite seu itinerário',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),
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
              child: ListView.builder(
                itemCount: _atividades.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_atividades[index]['titulo']!),
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        // Deslizar para a direita (editar)
                        await _confirmarExclusao(index);
                        return false; // Não realizar ação de exclusão automática
                      } else if (direction == DismissDirection.startToEnd) {
                        // Deslizar para a esquerda (editar)
                        bool? result = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Deseja editar esta atividade?'),
                            content: Text(
                                'Você selecionou editar a atividade "${_atividades[index]['titulo']}".'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text('Editar'),
                              ),
                            ],
                          ),
                        );
                        if (result == true) {
                          _editarAtividade(index);
                        }
                        return false; // Impede que o deslize finalize
                      }
                      return false;
                    },
                    background: Container(
                      color: Colors.blue, // Cor para deslizar para a direita
                      alignment: Alignment.centerLeft, // Ícone de editar
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red, // Cor para deslizar para a esquerda
                      alignment: Alignment.centerRight, // Ícone de excluir
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/locations', (route) => false),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Row(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _atividades[index]['titulo']!,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _atividades[index]['horario']!,
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Text(
                            _atividades[index]['localizacao']!,
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                  );
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título da atividade',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF266B70)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF266B70)),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _horarioController,
                  decoration: InputDecoration(
                    labelText: 'Horário',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF266B70)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF266B70)),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _localizacaoController,
                  decoration: InputDecoration(
                    labelText: 'Localização',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF266B70)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF266B70)),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 16),
              ],
            ),
            ElevatedButton(
              onPressed: _adicionarAtividade,
              child: Text(
                _indiceEdicao == null ? 'Adicionar' : 'Editar',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(29, 84, 88, 1),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(100, 40)),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Salvar itinerário',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
