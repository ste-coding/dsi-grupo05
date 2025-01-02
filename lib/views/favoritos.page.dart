import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:flutter_application_1/views/localizacoes.page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  // Método para abrir a caixa de diálogo para adicionar/editar localização
  void openNoteBox() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationOptionsPage()),
    );

    if (selectedLocation != null) {
      final existingNotes = await firestoreService.getNotesStream().first;
      bool locationExists =
          existingNotes.docs.any((doc) => doc['note'] == selectedLocation);

      if (locationExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esta localização já foi salva!')),
        );
      } else {
        firestoreService.addNote(selectedLocation); // SALVA NO FIRESTORE
      }
    }
  }

  void editNote({required String docID, String? currentLocation}) async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LocationOptionsPage(initialLocation: currentLocation)),
    );

    if (selectedLocation != null && selectedLocation != currentLocation) {
      final existingNotes = await firestoreService.getNotesStream().first;
      bool locationExists =
          existingNotes.docs.any((doc) => doc['note'] == selectedLocation);

      if (locationExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Localização já cadastrada!')),
        );
      } else {
        // Atualiza a nota no Firestore se a localização não existir
        firestoreService.updateNote(
            docID, selectedLocation); // ATUALIZA NO FIRESTORE
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFEAF1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/menu', (route) => false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), //FAVORTIOS
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            const Text(
              'Favoritos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),
            const SizedBox(height: 8), //TEXTO 1
            Text(
              'Visualize ou edite sua lista de desejos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'Localizações salvas', //TEXTO 2
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 20),

            // Lista de localizações salvas
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getNotesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List notesList = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: notesList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = notesList[index];
                        String docID = document.id;
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String noteText = data['note'];

                        return Dismissible(
                          key: Key(docID),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            firestoreService.deleteNote(docID);
                          },
                          background: Container(
                            // DELETAR
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: GestureDetector(
                            //EDITAR
                            onTap: () => editNote(
                                docID: docID, currentLocation: noteText),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(noteText),
                                  const Icon(
                                    Icons.favorite,
                                    color: const Color(0xFF266B70),
                                    size: 20.0,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("Não há nada salvo"));
                  }
                },
              ),
            ),
          ],
        ),
      ),

      // Botão circular no canto inferior direito
      floatingActionButton: FloatingActionButton(
        //CRIAR NOVO FAVORITO
        onPressed: () => openNoteBox(),
        backgroundColor: const Color(0xFF266B70),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
