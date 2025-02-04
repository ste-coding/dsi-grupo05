import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../widgets/local_card.dart';
import '../services/firestore/favoritos.service.dart';
import '../models/local_model.dart';

class ExplorePage extends StatefulWidget {
  final Function(LocalModel local) onSelectedLocal;

  ExplorePage({required this.onSelectedLocal});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLocais();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadLocais() {
    final localController =
        Provider.of<LocalController>(context, listen: false);
    String searchTerm = _searchController.text.trim();
    String location = 'Brasil';
    if (searchTerm.isNotEmpty) {
      localController.fetchLocais(searchTerm, location);
    } else {
      localController.fetchLocais('', location);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final localController =
          Provider.of<LocalController>(context, listen: false);
      if (!localController.isLoading && !localController.finishLoading) {
        _loadLocais();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explorar Locais'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Pesquisar por locais...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _loadLocais();
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<LocalController>(
                builder: (context, controller, child) {
                  if (controller.isLoading && controller.locais.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage != null) {
                    return Center(child: Text(controller.errorMessage!));
                  }

                  if (controller.locais.isEmpty) {
                    return Center(child: Text('Nenhum local encontrado.'));
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!controller.isLoading &&
                          !controller.finishLoading &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        _loadLocais();
                      }
                      return true;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: controller.locais.length +
                          (controller.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.locais.length) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final local = controller.locais[index];

                        final userId = 'user-id-aqui'; 

                        final favoritosService = FavoritosService(userId);

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LocalCard(
                            local: local,
                            favoritosService: favoritosService,
                          ),
                        );
                      },
                    ),
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
