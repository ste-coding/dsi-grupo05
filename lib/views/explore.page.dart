import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../widgets/local_card.dart';
import '../services/firestore/favoritos.service.dart';
import '../models/local_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/star_rating.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<LocalModel> _allLocais = [];
  List<LocalModel> _filteredLocais = [];
  double _mediaEstrelasFilter = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadAllLocais();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final localController = Provider.of<LocalController>(context, listen: false);
      String searchTerm = _searchController.text.trim();

      if (!localController.isLoading && !localController.finishLoading) {
        setState(() {
          _isLoadingMore = true;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (!localController.isLoading && !localController.finishLoading) {
            _loadLocais(searchTerm);
          }
          setState(() {
            _isLoadingMore = false;
          });
        });
      }
    }
  }

  Future<void> _loadAllLocais() async {
    final localController = Provider.of<LocalController>(context, listen: false);

    try {
      await localController.fetchLocais('', '');
      _allLocais = localController.locaisProximos;
      setState(() {
        _filteredLocais = _allLocais;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar locais. Tente novamente.'),
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: _loadAllLocais,
          ),
        ),
      );
    }
  }

  Future<void> _loadLocais(String searchTerm) async {
    final localController = Provider.of<LocalController>(context, listen: false);

    localController.clearErrorMessage();

    try {
      final filteredResults = await Future.wait(_allLocais.map((local) async {
        final mediaEstrelas = await localController.fetchMediaEstrelasFromFirestore(local.id);

        final matchesSearch = searchTerm.isEmpty ||
            local.nome.toLowerCase().contains(searchTerm.toLowerCase());
        final matchesRating = mediaEstrelas >= _mediaEstrelasFilter;
        return matchesSearch && matchesRating ? local : null;
      }).toList());

      setState(() {
        _filteredLocais = filteredResults.where((local) => local != null).cast<LocalModel>().toList();
      });

      if (_filteredLocais.isEmpty && localController.errorMessage == null) {
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar locais. Tente novamente.'),
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: () => _loadLocais(searchTerm),
          ),
        ),
      );
    }
  }

  void _onMediaEstrelasChanged(double newRating) {
    setState(() {
      _mediaEstrelasFilter = newRating;
      _loadLocais(_searchController.text.trim());
    });
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
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Digite o nome do local...',
                              hintStyle: TextStyle(fontFamily: 'Poppins'),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 15),
                            ),
                            style: const TextStyle(fontFamily: 'Poppins'),
                            onChanged: (value) {
                              _loadLocais(value);
                            },
                            onSubmitted: (value) {
                              _searchFocusNode.unfocus();
                              _loadLocais(value);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            final location = _searchController.text.trim();
                            if (location.isNotEmpty) {
                              await _loadLocais(location);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  StarRatingSlider(
                    rating: _mediaEstrelasFilter,
                    onChanged: _onMediaEstrelasChanged,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<LocalController>(
                builder: (context, controller, child) {
                  if (controller.isLoading && _filteredLocais.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage != null && _filteredLocais.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(controller.errorMessage!),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadLocais(_searchController.text.trim()),
                          child: Text('Tentar novamente'),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: _filteredLocais.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _filteredLocais.length) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final local = _filteredLocais[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LocalCard(
                          local: local,
                          favoritosService: favoritosService,
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