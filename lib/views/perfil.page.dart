import 'package:flutter/material.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Adicione a lógica para editar o perfil, caso necessário
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exemplo de uma imagem de perfil
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://www.example.com/your-profile-image.jpg'), // Substitua pela URL ou imagem local
              ),
            ),
            const SizedBox(height: 20),
            // Exemplo de informações do usuário
            const Text(
              'Nome: João da Silva',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'E-mail: joao.silva@email.com',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Localização: São Paulo, SP',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            // Botões para outras ações
            ElevatedButton(
              onPressed: () {
                // Lógica para editar o perfil, ou realizar outras ações
              },
              child: const Text('Editar Perfil'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para deslogar ou realizar logout
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
