import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/local_controller.dart';
import '../services/firestore/favoritos.service.dart';
import '../widgets/local_card.dart';
import '../models/local_model.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localController = Provider.of<LocalController>(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Usuário não autenticado.'));
    }

    final favoritosService = FavoritosService(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favoritos',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<LocalModel>>(
        stream: favoritosService.getFavoritosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final favoritos = snapshot.data ?? [];

          if (favoritos.isEmpty) {
            return const Center(child: Text('Nenhum favorito encontrado.'));
          }

          return ListView.builder(
            itemCount: favoritos.length,
            itemBuilder: (context, index) {
              final local = favoritos[index];

              return Dismissible(
                key: Key(local.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  await favoritosService.removeFavorito(local.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${local.nome} removido dos favoritos')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: LocalCard(
                  local: local,
                  favoritosService: favoritosService,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
