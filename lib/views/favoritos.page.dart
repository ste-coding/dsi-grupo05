import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  final FirestoreService firestoreService = FirestoreService();
  String buttonText = 'Adicionar Localização';

  // controlador de texto
  final TextEditingController textController = TextEditingController();

  // caixa de dialogo para adicionar local
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          // botão para salvar
          ElevatedButton(
            onPressed: () {
              // add firestore
              if (docID == null) {
                firestoreService.addNote(textController.text);
              } else {
                firestoreService.updateNote(docID, textController.text);
              }

              // limpar caixa
              textController.clear();

              // tirar caixa da tela
              Navigator.pop(context);
            },
            child: Text("Salvar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFEAF1),
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
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              'Favoritos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Visualize ou edite sua lista de desejos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Localizações salvas',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20),

            // Lista de boxes de localizações usando o StreamBuilder
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getNotesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List notesList = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: notesList.length,
                      itemBuilder: (context, index) {
                        // localizações salvas
                        DocumentSnapshot document = notesList[index];
                        String docID = document.id;

                        // pegar nota de cada doc
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        String noteText = data['note'];

                        return Dismissible(
                          key: Key(docID),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            firestoreService.deleteNote(docID);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            title: Text(noteText),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // botao de edição
                                IconButton(
                                  onPressed: () => openNoteBox(docID: docID),
                                  icon: Icon(Icons.edit),
                                ),

                                // botao de excluir
                                IconButton(
                                  onPressed: () => firestoreService.deleteNote(docID),
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Text("Não há nada salvo");
                  }
                },
              ),
            ),

            // Botão para adicionar localizações
            Center(
              child: SizedBox(
                width: 250,
                height: 48,
                child: OutlinedButton(
                  onPressed: openNoteBox,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
                    backgroundColor: Color(0xFF266B70),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
