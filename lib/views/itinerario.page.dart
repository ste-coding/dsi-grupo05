import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'criar_itinerario.page.dart';
import '../services/firestore.dart';

class ItinerarioPage extends StatefulWidget {
  const ItinerarioPage({super.key});

  @override
  State<ItinerarioPage> createState() => _ItinerarioPageState();
}

class _ItinerarioPageState extends State<ItinerarioPage> {
  final FirestoreService _firestoreService = FirestoreService();

  // Função para adicionar ou atualizar itinerário
  void _adicionarOuAtualizarItinerario(Map<String, String> itinerario,
      {int? index, String? docID}) {
    if (docID == null) {
      // Cria um novo itinerário
      _firestoreService.addItinerario(itinerario);
    } else {
      // Atualiza o itinerário existente
      _firestoreService.updateItinerario(docID, itinerario);
    }
  }

  // Função para excluir itinerário com confirmação
  Future<bool?> _confirmarExclusao(String docID) async {
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getItinerariosStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum itinerário adicionado ainda.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                    fontSize: 16,
                  ),
                ),
              );
            }

            final itinerarios = snapshot.data!.docs;

            return ListView.builder(
              itemCount: itinerarios.length,
              itemBuilder: (context, index) {
                final itinerario = itinerarios[index];
                final docID = itinerario.id;
                final data = itinerario.data() as Map<String, dynamic>;

                return Dismissible(
                  key: Key(docID),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    bool? confirmarExclusao = await _confirmarExclusao(docID);
                    if (confirmarExclusao == true) {
                      await _firestoreService.deleteItinerario(docID);
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
                      title: Text(data['titulo'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${data['horario']} - ${data['localizacao']}'),
                          // Adicionando a exibição das observações
                          if (data['observacoes'] != null && data['observacoes'].isNotEmpty)
                            Text('Observações: ${data['observacoes']}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CriarItinerarioPage(
                              onSalvarItinerario: (novoItinerario) {
                                _adicionarOuAtualizarItinerario(
                                  novoItinerario,
                                  docID: docID, // Atualiza o itinerário
                                );
                              },
                              itinerarioExistente: data.map((key, value) => MapEntry(key, value.toString())),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
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