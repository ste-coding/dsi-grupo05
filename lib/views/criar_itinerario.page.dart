import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore/itinerarios.service.dart';
import 'package:flutter_application_1/models/itinerario_model.dart';

class CreateItinerarioPage extends StatefulWidget {
  final String userId;

  CreateItinerarioPage({required this.userId});

  @override
  _CreateItinerarioPageState createState() => _CreateItinerarioPageState();
}

class _CreateItinerarioPageState extends State<CreateItinerarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _observationsController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final itinerariosService = ItinerariosService(widget.userId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Itinerário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _observationsController,
                decoration: InputDecoration(labelText: 'Observações'),
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'URL da Imagem'),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
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
                    child: Text(_startDate == null
                        ? 'Início'
                        : _startDate!.toIso8601String()),
                  ),
                  SizedBox(width: 16),
                  TextButton(
                    onPressed: () async {
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
                    child: Text(
                        _endDate == null ? 'Fim' : _endDate!.toIso8601String()),
                  ),
                ],
              ),
              Spacer(),
              ElevatedButton(
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
                      id: '', //ver se está gerando o id automatico
                      userId: widget.userId,
                      titulo: _tituloController.text,
                      startDate: _startDate!,
                      endDate: _endDate!,
                      observations: _observationsController.text,
                      imageUrl: _imageUrlController.text,
                      locais: [],
                    );

                    await itinerariosService.addItinerario(itinerario.toFirestore());
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
