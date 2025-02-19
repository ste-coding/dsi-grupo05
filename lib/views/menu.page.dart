import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../widgets/local_card.dart';
import 'explore.page.dart';
import '../services/firestore/favoritos.service.dart';
import '../models/local_model.dart';

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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeader(),
              
              // Featured locations section
              _buildFeaturedLocationsSection(),

              const SizedBox(height: 24),

              // Nearby locations section
              _buildNearbyLocationsSection(),

              // Bottom navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Explorar Locais',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
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

  Widget _buildFeaturedLocationsSection() {
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
          height: 320,
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
                      child: LocalCard(
                        local: local,
                        favoritosService: FavoritosService('user-id'),
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

  Widget _buildNearbyLocationsSection() {
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
          height: 320,
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
                      child: LocalCard(
                        local: local,
                        favoritosService: FavoritosService('user-id'),
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

  Widget _buildBottomNavigation() {
    return Container(
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
            _buildNavItem(Icons.star_border, 'Avaliações', false),
            _buildNavItem(Icons.gps_fixed, 'Mapa', false),
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
              MaterialPageRoute(
                builder: (context) => ExplorePage(
                  onSelectedLocal: (local) {
                    print("Local selecionado: ${local.nome}");
                  },
                ),
              ),
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
            color: isSelected ? const Color(0xFF266B70) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: isSelected ? const Color(0xFF266B70) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
