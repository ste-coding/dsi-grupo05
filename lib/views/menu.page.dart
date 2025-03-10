import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../widgets/local_card.dart';
import 'explore.page.dart';
import '../services/firestore/favoritos.service.dart';
import '../models/local_model.dart';
import '../services/firestore/user.service.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  void initState() {
    super.initState();
    _loadFeaturedLocations();
    _loadNearbyLocations();
  }

  void _loadFeaturedLocations() {
    final localController =
        Provider.of<LocalController>(context, listen: false);
    localController.fetchLocais('', 'Brasil');
  }

  void _loadNearbyLocations() {
    final localController =
        Provider.of<LocalController>(context, listen: false);
    localController.fetchLocaisProximos();
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final userId = userService.auth.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text("Usuário não autenticado."));
    }

    return ChangeNotifierProvider(
      create: (_) => FavoritosService(userId),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(userService, userId),
                // New header section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Explore novos locais',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Bora Lá?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFeaturedLocationsSection(userId),

                const SizedBox(height: 24),

                // Nearby locations section
                _buildNearbyLocationsSection(userId),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Adding the BottomNavigationBar here
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  // Add the BottomNavigationBar function here
  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0, // Modify this to set the selected index dynamically
      selectedItemColor: const Color.fromARGB(255, 1, 168, 151),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
          tooltip: 'Home',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Itinerários',
          tooltip: 'Itinerários',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
          tooltip: 'Buscar',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gps_fixed),
          label: 'Mapa',
          tooltip: 'Mapa',
          backgroundColor: Colors.white,
        ),
      ],
      selectedLabelStyle: TextStyle(fontFamily: 'Poppins'),
      unselectedLabelStyle: TextStyle(fontFamily: 'Poppins'),
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/menu');
            break;
          case 1:
            Navigator.pushNamed(context, '/itinerario');
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ExplorePage(onSelectedLocal: (local) {
                        print("Local selecionado: ${local.nome}");
                      })),
            );
            break;
          case 3:
            Navigator.pushNamed(context, '/mapa');
            break;
        }
      },
    );
  }
  Widget _buildHeader(UserService userService, String userId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: userService.getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    return const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                    );
                  }

                  final userData = snapshot.data!;
                  final profilePictureBase64 = userData['profilePicture'];
                  final profileImage = profilePictureBase64 != null
                      ? Image.memory(base64Decode(profilePictureBase64)).image
                      : null;

                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/perfil');
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: profileImage,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              FutureBuilder<Map<String, dynamic>?>(
                future: userService.getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      'Carregando...',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text(
                      'Erro ao carregar nome',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Text(
                      'Nome não encontrado',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }

                  final nome = snapshot.data!['nome'] ?? '';
                  final primeiroNome = nome.split(' ').first;

                  return Text(
                    'Olá, $primeiroNome',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  );
                },
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
    );
  }

  Widget _buildFeaturedLocationsSection(String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Locais em destaque',
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
                    MaterialPageRoute(
                      builder: (context) => ExplorePage(
                        onSelectedLocal: (local) {
                          print("Local selecionado: ${local.nome}");
                        },
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Ver mais',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Color(0xFF266B70),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 370,
          child: Consumer<LocalController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.featuredLocations.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Nenhum local em destaque encontrado',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: controller.featuredLocations.length,
                itemBuilder: (context, index) {
                  final local = controller.featuredLocations[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 280,
                      child: Consumer<FavoritosService>(
                        builder: (context, favoritosService, child) {
                          return LocalCard(
                            local: local,
                            favoritosService: favoritosService,
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
      ],
    );
  }

  Widget _buildNearbyLocationsSection(String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Locais pertinho de você',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 370,
          child: Consumer<LocalController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.locaisProximos.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Nenhum local próximo encontrado',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: controller.locaisProximos.length,
                itemBuilder: (context, index) {
                  final local = controller.locaisProximos[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 280,
                      child: Consumer<FavoritosService>(
                        builder: (context, favoritosService, child) {
                          return LocalCard(
                            local: local,
                            favoritosService: favoritosService,
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
      ],
    );
  }
}
