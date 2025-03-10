import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert'; // Para usar base64Decode
import '../models/local_user_model.dart';
import '../views/cadastro_local.page.dart';

class MeusEstabelecimentosPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MeusEstabelecimentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Estabelecimentos',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent, // Fundo transparente
        elevation: 0, // Sem sombra
        centerTitle: true, // Título centralizado
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Ícone preto
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('locais_usuario') // Coleção correta
            .where('usuarioId', isEqualTo: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print("Nenhum documento encontrado na coleção 'locais_usuario'."); // Log de depuração
            return Center(
              child: Text(
                'Nenhum estabelecimento cadastrado.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
            );
          }

          final locais = snapshot.data!.docs.map((doc) {
            print("Documento encontrado: ${doc.data()}"); // Log de depuração
            return LocalUserModel.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: locais.length,
            itemBuilder: (context, index) {
              final local = locais[index];
              return Dismissible(
                key: Key(local.id), // Chave única para cada item
                direction: DismissDirection.endToStart, // Arrastar da direita para a esquerda
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  color: Colors.red, // Cor de fundo ao arrastar
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  // Diálogo de confirmação antes de deletar
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Excluir Estabelecimento', style: TextStyle(fontFamily: 'Poppins')),
                      content: Text('Tem certeza que deseja excluir este estabelecimento?', style: TextStyle(fontFamily: 'Poppins')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancelar', style: TextStyle(fontFamily: 'Poppins')),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Excluir', style: TextStyle(color: Colors.red, fontFamily: 'Poppins')),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  // Excluir o local após confirmação
                  try {
                    await _firestore.collection('locais_usuario').doc(local.id).delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Estabelecimento excluído com sucesso!', style: TextStyle(fontFamily: 'Poppins'))),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir estabelecimento: $e', style: TextStyle(fontFamily: 'Poppins'))),
                    );
                  }
                },
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CadastroLocalPage(local: local),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagem do local
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                            child: local.imagem.isNotEmpty
                                ? (local.imagem.startsWith('http')
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          local.imagem,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(Icons.broken_image, size: 40, color: Colors.grey);
                                          },
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(local.imagem),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(Icons.broken_image, size: 40, color: Colors.grey);
                                          },
                                        ),
                                      ))
                                : Icon(Icons.place, size: 40, color: Colors.grey),
                          ),
                          SizedBox(width: 16),
                          // Nome e cidade do local
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  local.nome,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  local.cidade,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CadastroLocalPage(),
            ),
          );
        },
        backgroundColor: Color(0xFF266B70), // Cor verde água
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}