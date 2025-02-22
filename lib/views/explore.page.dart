import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../widgets/local_card.dart';
import '../services/firestore/favoritos.service.dart';
import '../models/local_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExplorePage extends StatefulWidget {
  final Function(LocalModel local) onSelectedLocal;

  const ExplorePage({super.key, required this.onSelectedLocal});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final localController =
          Provider.of<LocalController>(context, listen: false);
      String searchTerm = _searchController.text.trim();
      
      if (searchTerm.isNotEmpty && 
          !localController.isLoading && 
          !localController.finishLoading) {
        setState(() {
          _isLoadingMore = true;
        });
        
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!localController.isLoading && 
              !localController.finishLoading) {
            _loadLocais();
          }
          setState(() {
            _isLoadingMore = false;
          });
        });
      }
    }
  }

  Future<void> _loadLocais() async {
    final localController =
        Provider.of<LocalController>(context, listen: false);
    String searchTerm = _searchController.text.trim();
    
    if (localController.isLoading || searchTerm.isEmpty) {
      return;
    }

    localController.clearErrorMessage();

    try {
      if (localController.searchResults.isEmpty) {
        localController.resetLocais();
      }
      
      await localController.fetchLocais(searchTerm, searchTerm);
      
      if (localController.searchResults.isEmpty && 
          localController.errorMessage == null) {
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar locais. Tente novamente.'),
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: _loadLocais,
          ),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Explorar Locais',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        body: Center(child: Text('Usuário não autenticado.')),
      );
    }

    final favoritosService = FavoritosService(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explorar Locais',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Digite o nome do local...',
                  hintStyle: const TextStyle(fontFamily: 'Poppins'),
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _loadLocais();
                          },
                        )
                      : null,
                ),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
                onSubmitted: (value) {
                  _searchFocusNode.unfocus();
                  _loadLocais();
                },
              ),
            ),
            Expanded(
              child: Consumer<LocalController>(
                builder: (context, controller, child) {
                  if (controller.isLoading && controller.searchResults.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage != null && 
                      controller.searchResults.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(controller.errorMessage!),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLocais,
                          child: Text('Tentar novamente'),
                        ),
                      ],
                    );
                  }

                  if (_searchController.text.isEmpty) {
                    return ListView.builder(
                      itemCount: controller.locaisProximos.length,
                      itemBuilder: (context, index) {
                        final local = controller.locaisProximos[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LocalCard(
                            local: local,
                            favoritosService: favoritosService,
                          ),
                        );
                      },
                    );
                  }

                  if (controller.searchResults.isEmpty && 
                      _searchController.text.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Nenhum local encontrado',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF266B70),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              textStyle: const TextStyle(fontFamily: 'Poppins'),
                            ),
                            onPressed: _loadLocais,
                            child: Text('Tentar novamente', style: const TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Resultados para "${_searchController.text}"',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
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
                            itemCount: controller.searchResults.length +
                                (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == controller.searchResults.length) {
                                return Center(child: CircularProgressIndicator());
                              }
                              final local = controller.searchResults[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LocalCard(
                                  local: local,
                                  favoritosService: favoritosService,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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