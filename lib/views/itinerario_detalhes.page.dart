import 'package:flutter/material.dart';
import '../models/itinerario_model.dart';
import '../widgets/roteiro_tab.dart';
import '../controller/local_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/foursquare_service.dart';
import 'package:flutter_application_1/services/firestore/itinerarios.service.dart';
import 'package:flutter_application_1/services/firestore/favoritos.service.dart';
import 'package:flutter_application_1/repositories/local_repository.dart';
import 'package:flutter_application_1/widgets/checklist_tab.dart';

class ItinerarioDetalhesPage extends StatefulWidget {
  final ItinerarioModel itinerario;

  const ItinerarioDetalhesPage({super.key, required this.itinerario});

  @override
  _ItinerarioDetalhesPageState createState() => _ItinerarioDetalhesPageState();
}

class _ItinerarioDetalhesPageState extends State<ItinerarioDetalhesPage>
  with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _observacoesController = TextEditingController();
  
  late LocalController _localController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _observacoesController.text = widget.itinerario.observations;

    _localController = LocalController(
      LocalRepository(FoursquareService()),
      FavoritosService(FirebaseAuth.instance.currentUser?.uid ?? ""),
      ItinerariosService(FirebaseAuth.instance.currentUser?.uid ?? ""),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.itinerario.titulo,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              background: Image.network(
                widget.itinerario.imageUrl.isNotEmpty
                    ? widget.itinerario.imageUrl
                    : '../assets/images/placeholder_image.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Geral'),
                    Tab(text: 'Roteiro'),
                    Tab(text: 'Checklist'),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Aba Geral
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Período da Viagem',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_formatDate(widget.itinerario.startDate)} - ${_formatDate(widget.itinerario.endDate)}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
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
                                      widget.itinerario.observations.isNotEmpty
                                          ? widget.itinerario.observations
                                          : 'Sem descrição',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Observações',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _observacoesController,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Adicione suas observações aqui...',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Observações salvas com sucesso!'),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF266B70),
                                          textStyle: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        child: const Text(
                                          'Salvar Observações',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      RoteiroTab(
                        itinerario: widget.itinerario,
                      ),
                      ChecklistTab(
                        itinerarioId: widget.itinerario.id,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
