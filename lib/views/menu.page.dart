import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/pontos_turisticos_service.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final PontosTuristicosService _pontosTuristicosService = PontosTuristicosService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Temporário'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pushNamed(context, '/favoritos');
              },
            ),
            ListTile(
              title: const Text('Itinerarios'),
              onTap: () {
                Navigator.pushNamed(context, '/itinerario');
              },
            ),
            ListTile(
              title: const Text('Sair'),
              onTap: () {
                Navigator.pushNamed(context, '/inicial');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Que tal conhecer...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _pontosTuristicosService.getPontosTuristicos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Erro ao carregar os pontos turísticos.'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nenhum ponto turístico encontrado.'));
                  }

                  final points = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: points.length,
                    itemBuilder: (context, index) {
                      final point = points[index];
                      final name = point['name'];
                      final city = point['city'];
                      final state = point['state'];
                      final stars = point['stars'] ?? 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(name, style: const TextStyle(fontSize: 18)),
                          subtitle: Text('$city, $state', style: const TextStyle(fontSize: 16)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.yellow[700]),
                              Text('$stars', style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
