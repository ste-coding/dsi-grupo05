import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'criar_itinerario.page.dart';
import 'checklist.page.dart';
import 'package:flutter_application_1/services/firestore/itinerarios.service.dart';

class ItinerarioPage extends StatefulWidget {
  const ItinerarioPage({super.key});

  @override
  State<ItinerarioPage> createState() => _ItinerarioPageState();
}

class _ItinerarioPageState extends State<ItinerarioPage> {
  late final ItinerariosService _firestoreService;

  @override
  void initState() {
    super.initState();
    _initializeFirestoreService();
  }

  void _initializeFirestoreService() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      _firestoreService = ItinerariosService(userId);
    } else {
      // Tratar caso o usuário não esteja autenticado
      print("Usuário não autenticado");
    }
  }

  void _adicionarOuAtualizarItinerario(Map<String, String> itinerario,
      {int? index, String? docID}) {
    if (docID == null) {
      _firestoreService.addItinerario(itinerario);
    } else {
      _firestoreService.updateItinerario(docID, itinerario);
    }
  }

  Future<bool?> _confirmarExclusao(String docID) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Itinerário'),
          content: const Text(
              'Você tem certeza que deseja excluir este itinerário?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFEAF1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
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
              return const Center(child: CircularProgressIndicator());
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
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16.0),
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
                          if (data['observacoes'] != null &&
                              data['observacoes'].isNotEmpty)
                            Text('Observações: ${data['observacoes']}'),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChecklistPage(
                                        docID:
                                            docID),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.checklist,
                                  color: Colors.blue),
                              label: const Text('Checklist'),
                            ),
                          ),
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
                                  docID: docID,
                                );
                              },
                              itinerarioExistente: data.map((key, value) =>
                                  MapEntry(key, value.toString())),
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
