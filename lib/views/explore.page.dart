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
  List<LocalModel> _allLocais = []; // Lista para armazenar todos os locais
  List<LocalModel> _filteredLocais = []; // Lista para armazenar os locais filtrados
  double _mediaEstrelasFilter = 0; // Valor inicial do filtro de média de estrelas

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadAllLocais(); // Carregar todos os locais quando a página for inicializada
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
      await localController.fetchLocais('', ''); // Carregar todos os locais inicialmente
      _allLocais = localController.locaisProximos; // Armazenar todos os locais
      setState(() {
        _filteredLocais = _allLocais; // Exibir todos os locais inicialmente
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
      final filteredResults = _allLocais.where((local) {
        final matchesSearch = searchTerm.isEmpty ||
            local.nome.toLowerCase().contains(searchTerm.toLowerCase());
        final matchesRating = local.mediaEstrelas >= _mediaEstrelasFilter;
        return matchesSearch && matchesRating;
      }).toList();

      setState(() {
        _filteredLocais = filteredResults; // Exibir os locais filtrados
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

    return ChangeNotifierProvider(
      create: (_) => FavoritosService(userId),
      child: Scaffold(
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
                    TextField(
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
                                  _loadLocais('');
                                },
                              )
                            : null,
                      ),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                      onChanged: (value) {
                        _loadLocais(value); // Filtrar os locais com base no termo de busca
                      },
                      onSubmitted: (value) {
                        _searchFocusNode.unfocus();
                        _loadLocais(value);
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Filtrar por Média de Estrelas:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Slider(
                            value: _mediaEstrelasFilter,
                            activeColor: Color(0xFF266B70),
                            min: 0,
                            max: 10,
                            divisions: 10,
                            label: _mediaEstrelasFilter.round().toString(),
                            onChanged: _onMediaEstrelasChanged,
                          ),
                        ),
                      ],
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

                    if (_filteredLocais.isEmpty && _searchController.text.isNotEmpty) {
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
                              onPressed: () => _loadLocais(_searchController.text.trim()),
                              child: Text('Tentar novamente', style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
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
                          child: Consumer<FavoritosService>(
                            builder: (context, favoritosService, child) {
                              return LocalCard(
                                local: local,
                                favoritosService: favoritosService,
                              );
                            },
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
      ),
    );
  }
}