import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../models/local_model.dart';
import '../widgets/local_card.dart';
import 'explore.page.dart';
import '../services/firestore/favoritos.service.dart';
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
    _loadLocais();
    _loadLocaisProximos();
  }

  void _loadLocais() {
    final localController =
        Provider.of<LocalController>(context, listen: false);
    localController.fetchLocais('', 'Brasil');
  }

  void _loadLocaisProximos() {
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                        FutureBuilder<Map<String, dynamic>?>(
                          future: userService.getUserData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey,
                              );
                            }

                            if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data == null) {
                              return const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey,
                              );
                            }

                            final userData = snapshot.data!;
                            final profilePictureBase64 =
                                userData['profilePicture'];
                            final profileImage = profilePictureBase64 != null
                                ? Image.memory(
                                        base64Decode(profilePictureBase64))
                                    .image
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore novos lugares.',
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
                height: 320,
                child: Consumer<LocalController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.locais.isEmpty) {
                      return const Center(
                          child: Text('Nenhum local encontrado.'));
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
                            child: LocalCard(
                              local: local,
                              favoritosService: FavoritosService(userId),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
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
                height: 320,
                child: Consumer<LocalController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.locaisProximos.isEmpty) {
                      return const Center(
                          child: Text('Nenhum local próximo encontrado.'));
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
                            child: LocalCard(
                              local: local,
                              favoritosService: FavoritosService(userId),
                            ),
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
                      _buildNavItem(Icons.map, 'Itinerários', false),
                      _buildNavItem(Icons.search, 'Buscar', false),
                      _buildNavItem(Icons.gps_fixed, 'Mapa', false),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
              MaterialPageRoute(
                  builder: (context) => ExplorePage(
                        onSelectedLocal: (local) {
                          print("Local selecionado: ${local.nome}");
                        },
                      )),
            );
            break;
          case 'Avaliações':
            Navigator.pushNamed(context, '/avaliacoes');
            break;
          case 'Mapa':
            Navigator.pushNamed(context, '/mapa');
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color.fromARGB(255, 1, 168, 151)
                : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: isSelected
                  ? const Color.fromARGB(255, 1, 168, 151)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
