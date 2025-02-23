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
  final TextEditingController _descricaoController = TextEditingController();
  late DateTime _startDate;
  late DateTime _endDate;

  late LocalController _localController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _descricaoController.text = widget
        .itinerario.observations; // assuming you want to edit the description

    _startDate = widget.itinerario.startDate;
    _endDate = widget.itinerario.endDate;

    _localController = LocalController(
      LocalRepository(FoursquareService()),
      FavoritosService(FirebaseAuth.instance.currentUser?.uid ?? ""),
      ItinerariosService(FirebaseAuth.instance.currentUser?.uid ?? ""),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate ? _startDate : _endDate;
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF266B70), // Cor do calendário
            colorScheme: ColorScheme.light(
              primary: Color(0xFF266B70), // Cor dos botões e cabeçalhos
              secondary: Color(0xFF266B70), // Cor dos botões
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  void _saveItinerarioChanges() {
    widget.itinerario.startDate = _startDate;
    widget.itinerario.endDate = _endDate;
    widget.itinerario.observations = _descricaoController.text;

    Map<String, dynamic> updatedData = widget.itinerario.toFirestore();

    ItinerariosService(FirebaseAuth.instance.currentUser?.uid ?? "")
        .atualizarItinerario(widget.itinerario.id, updatedData)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alterações salvas com sucesso!')),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar alterações: $e')),
      );
    });
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
            backgroundColor: Color(0xFF266B70), // Cor da barra do AppBar
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.itinerario.titulo,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              background: widget.itinerario.imageUrl != null &&
                      widget.itinerario.imageUrl!.isNotEmpty
                  ? Image.network(
                      widget.itinerario.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    )
                  : Image.asset(
                      'assets/images/placeholder_image.png',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor:
                      Color(0xFF266B70), // Cor da barra de navegação
                  labelColor: Color(0xFF266B70), // Cor do texto das abas
                  unselectedLabelColor:
                      Colors.black, // Cor das abas não selecionadas
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: TextEditingController(
                                                text: _formatDate(_startDate)),
                                            readOnly: true,
                                            onTap: () =>
                                                _selectDate(context, true),
                                            decoration: InputDecoration(
                                              labelText: 'Data de Início',
                                              labelStyle: TextStyle(
                                                color: Color(0xFF266B70),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFF266B70),
                                                  width: 2,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFF266B70),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextField(
                                            controller: TextEditingController(
                                                text: _formatDate(_endDate)),
                                            readOnly: true,
                                            onTap: () =>
                                                _selectDate(context, false),
                                            decoration: InputDecoration(
                                              labelText: 'Data de Fim',
                                              labelStyle: TextStyle(
                                                color: Color(0xFF266B70),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFF266B70),
                                                  width: 2,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFF266B70),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
                                    TextField(
                                      controller: _descricaoController,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText:
                                            'Adicione uma descrição da viagem...',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xFF266B70),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: _saveItinerarioChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF266B70),
                                  textStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Menos arredondado
                                  ),
                                ),
                                child: const Text(
                                  'Salvar Alterações',
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
                      RoteiroPage(
                        startDate: widget.itinerario.startDate,
                        endDate: widget.itinerario.endDate,
                        roteiroId:
                            widget.itinerario.id, // Passando o id do itinerário
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
