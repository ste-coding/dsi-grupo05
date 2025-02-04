import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../models/local_model.dart';
import '../models/itinerario_model.dart';
import '../services/firestore/itinerarios.service.dart';
import '../widgets/itinerary_bottom_sheet.dart';

class LocalDetailsPage extends StatefulWidget {
  final LocalModel local;

  const LocalDetailsPage({super.key, required this.local});

  @override
  _LocalDetailsPageState createState() => _LocalDetailsPageState();
}

class _LocalDetailsPageState extends State<LocalDetailsPage> {
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    final localController = Provider.of<LocalController>(context, listen: false);
    bool favoritado = await localController.favoritosService.checkIfFavoritoExists(widget.local.id);
    setState(() {
      isFavorited = favoritado;
    });
  }

  void _toggleFavorite() async {
    final localController = Provider.of<LocalController>(context, listen: false);

    if (isFavorited) {
      await localController.removeFromFavoritos(widget.local.id);
    } else {
      await localController.addToFavoritos(widget.local.id);
    }

    setState(() {
      isFavorited = !isFavorited;
    });
  }

  void _addToItinerary() async {
    final localController = Provider.of<LocalController>(context, listen: false);
    final itinerarioItem = ItinerarioItem(
      localId: widget.local.id,
      localName: widget.local.nome,
      visitDate: DateTime.now(),
      comment: 'Comentário opcional',
    );

    final itinerario = ItinerarioModel(
      id: '',
      userId: 'userId',
      titulo: 'Título do Itinerário',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 2)),
      observations: 'Observações sobre o itinerário',
      imageUrl: '',
      locais: [itinerarioItem],
    );

    try {
      await localController.itinerariosService.addItinerario(itinerario.toFirestore());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local adicionado ao itinerário!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar local: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocalHeader(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildAddToItineraryButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          widget.local.imagem,
          fit: BoxFit.cover,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  Widget _buildLocalHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(widget.local.imagem),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.local.nome,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.local.cidade}, ${widget.local.estado}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.local.descricao,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToItineraryButton() {
    return ElevatedButton(
      onPressed: () {
        _showItineraryBottomSheet(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF01A897),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Adicionar a Itinerário',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: const Color.fromARGB(255, 1, 168, 151),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Itinerários'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Avaliações'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }

  void _showItineraryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ItineraryBottomSheet(local: widget.local);
      },
    );
  }
}
