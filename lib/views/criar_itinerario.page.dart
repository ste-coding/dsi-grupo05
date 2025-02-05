import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore/itinerarios.service.dart';
import 'package:flutter_application_1/models/itinerario_model.dart';
import 'package:flutter/services.dart';

class CreateItinerarioPage extends StatefulWidget {
  final String userId;
  final ItinerarioModel? itinerario; // Adicionando o itinerário para edição

  CreateItinerarioPage({required this.userId, this.itinerario});

  @override
  _CreateItinerarioPageState createState() => _CreateItinerarioPageState();
}

class _CreateItinerarioPageState extends State<CreateItinerarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _observationsController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TextEditingController _timeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final itinerariosService = ItinerariosService(widget.userId);

    return Scaffold(
      backgroundColor: const Color(0xFFDFEAF1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFDFEAF1),
        title: const Text(
          'Novo Itinerário',
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Campo de Título
                  _buildTextFormField(_tituloController, 'Título', false,
                      (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um título.';
                    }
                    return null;
                  }),
                  const SizedBox(height: 16),
                  // Campo de Observações
                  _buildTextFormField(
                      _observationsController, 'Observações', false, (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira observações.';
                    }
                    return null;
                  }),
                  const SizedBox(height: 24),
                  // Campo de Data Início
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Tamanho fixo para o campo de data
                    child: TextFormField(
                      controller: _startDate == null
                          ? null
                          : TextEditingController(
                              text: _startDate!
                                  .toIso8601String()
                                  .split('T')
                                  .first),
                      decoration: InputDecoration(
                        labelText: 'Data de Início',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo de Data Fim
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Tamanho fixo para o campo de data
                    child: TextFormField(
                      controller: _endDate == null
                          ? null
                          : TextEditingController(
                              text:
                                  _endDate!.toIso8601String().split('T').first),
                      decoration: InputDecoration(
                        labelText: 'Data de Fim',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = date;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo de Hora (aceitando qualquer caractere)
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Tamanho fixo para o campo de hora
                    child: TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: 'Hora',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a hora.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botão de salvar
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: OutlinedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() &&
                                  _startDate != null &&
                                  _endDate != null &&
                                  _timeController.text.isNotEmpty) {
                                setState(() {
                                  _isLoading = true;
                                });

                                final itinerario = ItinerarioModel(
                                  id: '', // ver se está gerando o id automático
                                  userId: widget.userId,
                                  titulo: _tituloController.text,
                                  startDate: _startDate!,
                                  endDate: _endDate!,
                                  observations: _observationsController.text,
                                  imageUrl:
                                      "", // Remover o campo de URL de imagem
                                  locais: [],
                                );

                                await itinerariosService
                                    .addItinerario(itinerario.toFirestore());

                                setState(() {
                                  _isLoading = false;
                                });

                                Navigator.pop(context);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF266B70), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Salvar',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label,
      bool isPassword, String? Function(String?) validator,
      {List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width *
            0.8, // Tamanho fixo para os campos
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black),
            filled: true,
            fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          obscureText: isPassword,
          validator: validator,
          inputFormatters: inputFormatters,
        ),
      ),
    );
  }
}
