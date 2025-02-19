// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/local_controller.dart';
import '../services/firestore/favoritos.service.dart';
import 'package:flutter_application_1/models/favorites_model.dart';
import '../widgets/local_card.dart';
import '../models/local_model.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localController = Provider.of<LocalController>(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Center(child: Text('Usuário não autenticado.'));
    }

    final favoritosService = FavoritosService(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
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
      body: StreamBuilder<List<FavoritoModel>>(
        stream: favoritosService.getFavoritosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final favoritos = snapshot.data ?? [];

          if (favoritos.isEmpty) {
            return Center(child: Text('Nenhum favorito encontrado.'));
          }

          return ListView.builder(
            itemCount: favoritos.length,
            itemBuilder: (context, index) {
              final favorito = favoritos[index];
              final local = localController.searchResults.firstWhere(

                (local) => local.id == favorito.localId,
                orElse: () => LocalModel(
                  id: '',
                  nome: '',
                  descricao: '',
                  imagem: '',
                  categoria: '',
                  cidade: '',
                  estado: '',
                  latitude: 0.0,
                  longitude: 0.0,
                  mediaEstrelas: 0.0,
                  totalAvaliacoes: 0,
                ),
              );

              return LocalCard(
                local: local,
                favoritosService: favoritosService,
              );
            },
          );
        },
      ),
    );
  }
}
