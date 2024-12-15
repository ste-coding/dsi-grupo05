import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Temporário'),
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.search))
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
    );
  }
}
