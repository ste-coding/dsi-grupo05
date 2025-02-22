import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore/itinerarios.service.dart';
import 'package:flutter_application_1/models/itinerario_model.dart';
import 'package:intl/intl.dart';

class CreateItinerarioPage extends StatefulWidget {
  final String userId;

  const CreateItinerarioPage({super.key, required this.userId});

  @override
  _CreateItinerarioPageState createState() => _CreateItinerarioPageState();
}

class _CreateItinerarioPageState extends State<CreateItinerarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _observationsController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  late ItinerariosService itinerariosService;

  @override
  void initState() {
    super.initState();
    itinerariosService = ItinerariosService(widget.userId);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primaryColor: const Color(0xFF266B70),
            colorScheme: ColorScheme.light(primary: const Color(0xFF266B70)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criar Itinerário',
          style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alinha o conteúdo ao topo
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    labelStyle: const TextStyle(color: Color(0xFF266B70)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  cursorColor: Colors.black,
                  textAlign: TextAlign.left,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Insira um título'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observationsController,
                  decoration: InputDecoration(
                    labelText: 'Observações',
                    labelStyle: const TextStyle(color: Color(0xFF266B70)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  cursorColor: Colors.black,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Selecione as Datas',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text('Data de Início',
                                    style: TextStyle(color: Color(0xFF266B70))),
                                TextButton(
                                  onPressed: () => _selectDate(context, true),
                                  child: Text(
                                    _startDate == null
                                        ? 'Selecione'
                                        : DateFormat('dd/MM/yyyy')
                                            .format(_startDate!),
                                    style: const TextStyle(
                                        color: Color(0xFF266B70)),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Data de Fim',
                                    style: TextStyle(color: Color(0xFF266B70))),
                                TextButton(
                                  onPressed: () => _selectDate(context, false),
                                  child: Text(
                                    _endDate == null
                                        ? 'Selecione'
                                        : DateFormat('dd/MM/yyyy')
                                            .format(_endDate!),
                                    style: const TextStyle(
                                        color: Color(0xFF266B70)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Centralizando o botão
                Center(
                  child: SizedBox(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            _startDate != null &&
                            _endDate != null) {
                          if (_startDate!.isAfter(_endDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'A data de início deve ser antes da data de fim.')),
                            );
                            return;
                          }

                          final itinerario = ItinerarioModel(
                            id: '',
                            userId: widget.userId,
                            titulo: _tituloController.text,
                            startDate: _startDate!,
                            endDate: _endDate!,
                            observations: _observationsController.text,
                            locais: [],
                          );

                          await itinerariosService
                              .addItinerario(itinerario.toFirestore());
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF266B70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Salvar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins', // Aplica a fonte Poppins
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
