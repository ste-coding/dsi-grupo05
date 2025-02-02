import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../models/local_model.dart';
import '../widgets/local_card.dart';
import 'explore.page.dart';
import '../services/firestore/favoritos.service.dart'; // Importe o FavoritosService
import '../services/firestore/user.service.dart'; // Importe o UserService

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocais();
  }

  void _loadLocais() {
    final localController =
        Provider.of<LocalController>(context, listen: false);
    localController.fetchLocais('', 'Brasil');
  }

  @override
  Widget build(BuildContext context) {
    // Obtendo o userId através do UserService
    final userService = Provider.of<UserService>(context);
    
    // Garantir que o usuário esteja autenticado
    final userId = userService.auth.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text("Usuário não autenticado."));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFDFEAF1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage('https://via.placeholder.com/40'),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Olá, username',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      Navigator.pushNamed(context, '/favoritos');
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explore novos\nlugares.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Bora lá?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 2,
                        width: 40,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 1, 168, 151),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recomendado para você',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExplorePage()),
                      );
                    },
                    child: const Text(
                      'Ver mais',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<LocalController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.locais.isEmpty) {
                    return const Center(child: Text('Nenhum local encontrado.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.locais.length,
                    itemBuilder: (context, index) {
                      final local = controller.locais[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 280,
                          child: LocalCard(local: local, favoritosService: FavoritosService(userId),),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home, 'Home', true),
                    _buildNavItem(Icons.map_outlined, 'Itinerários', false),
                    _buildNavItem(Icons.search, 'Buscar', false),
                    _buildNavItem(Icons.star_border, 'Avaliações', false),
                    _buildNavItem(Icons.person_outline, 'Perfil', false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return InkWell(
      onTap: () {
        switch (label) {
          case 'Home':
            Navigator.pushNamed(context, '/menu');
            break;
          case 'Itinerários':
            Navigator.pushNamed(context, '/itinerario');
            break;
          case 'Buscar':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExplorePage()),
            );
            break;
          case 'Avaliações':
            Navigator.pushNamed(context, '/avaliacoes');
            break;
          case 'Perfil':
            Navigator.pushNamed(context, '/perfil');
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color.fromARGB(255, 1, 168, 151) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: isSelected ? const Color.fromARGB(255, 1, 168, 151) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
