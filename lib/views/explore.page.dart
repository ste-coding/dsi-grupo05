import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../widgets/local_card.dart';
import '../services/firestore/favoritos.service.dart';
import '../services/firestore/user.service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocais();
  }

  void _loadLocais() {
    final localController = Provider.of<LocalController>(context, listen: false);
    localController.fetchLocais(_searchController.text, 'Brasil');
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    
    final userId = userService.auth.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text("Usuário não autenticado."));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFDFEAF1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFDFEAF1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Explorar Locais',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Pesquisar por locais...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _loadLocais,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<LocalController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage != null) {
                    return Center(child: Text(controller.errorMessage!));
                  }

                  if (controller.locais.isEmpty) {
                    return const Center(child: Text('Nenhum local encontrado.'));
                  }

                  return ListView.builder(
                    itemCount: controller.locais.length,
                    itemBuilder: (context, index) {
                      final local = controller.locais[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LocalCard(local: local, favoritosService: FavoritosService(userId)),
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
