import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../models/itinerario_model.dart';
import '../models/local_model.dart';
import 'package:intl/intl.dart'; 

class ItineraryBottomSheet extends StatefulWidget {
  final LocalModel local;

  const ItineraryBottomSheet({Key? key, required this.local}) : super(key: key);

  @override
  _ItineraryBottomSheetState createState() => _ItineraryBottomSheetState();
}

class _ItineraryBottomSheetState extends State<ItineraryBottomSheet> {
  List<ItinerarioModel> itinerarios = [];
  String? selectedItineraryId;
  DateTime selectedDate = DateTime.now();  // Data padrão

  @override
  void initState() {
    super.initState();
    _fetchUserItinerarios();
  }

  // Função para buscar os itinerários do usuário
  Future<void> _fetchUserItinerarios() async {
    final localController = Provider.of<LocalController>(context, listen: false);
    itinerarios = await localController.getUserItinerarios();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escolha um itinerário para adicionar o local:',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Verificar se há itinerários
          if (itinerarios.isEmpty)
            const Text('Você não possui itinerários. Crie um para adicionar o local.')
          else
            Expanded(
              child: ListView.builder(
                itemCount: itinerarios.length,
                itemBuilder: (context, index) {
                  final itinerario = itinerarios[index];
                  return CheckboxListTile(
                    title: Text(itinerario.titulo),
                    value: selectedItineraryId == itinerario.id,
                    onChanged: (bool? selected) {
                      setState(() {
                        selectedItineraryId = selected ?? false ? itinerario.id : null;
                      });
                    },
                  );
                },
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Selecione a data para a visita
          TextButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null && pickedDate != selectedDate) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
            child: Text(
              "Escolha a Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          
          const SizedBox(height: 16),
          
          ElevatedButton(
            onPressed: () {
              if (selectedItineraryId != null) {
                _addLocalToItinerary();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecione um itinerário')),
                );
              }
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
            child: const Text('Adicionar ao itinerário'),
          ),
        ],
      ),
    );
  }

  // Função para adicionar local ao itinerário
  Future<void> _addLocalToItinerary() async {
    final localController = Provider.of<LocalController>(context, listen: false);
    try {
      await localController.addLocalToRoteiro(selectedItineraryId!, widget.local, selectedDate);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local adicionado ao itinerário!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar local ao itinerário: $e')),
      );
      print("Erro ao adicionar local ao itinerário: $e");
    }
  }
}