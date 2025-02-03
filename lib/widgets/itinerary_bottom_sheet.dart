import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../models/itinerario_model.dart';

class ItineraryBottomSheet extends StatefulWidget {
  @override
  _ItineraryBottomSheetState createState() => _ItineraryBottomSheetState();
}

class _ItineraryBottomSheetState extends State<ItineraryBottomSheet> {
  List<ItinerarioModel> itinerarios = [];
  Map<String, bool> selectedItinerarios = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserItinerarios();
  }

  Future<void> _fetchUserItinerarios() async {
    final localController = Provider.of<LocalController>(context, listen: false);
    
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedItinerarios = await localController.getUserItinerarios();
      
      if (fetchedItinerarios.isEmpty) {
        print("Nenhum itinerário encontrado.");
      } else {
        print("Itinerários carregados: ${fetchedItinerarios.length}");
      }

      setState(() {
        itinerarios = fetchedItinerarios;
        selectedItinerarios = {
          for (var itinerario in itinerarios) itinerario.id: false
        };
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar itinerários: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (itinerarios.isEmpty) {
      return Center(child: Text('Você não possui itinerários.'));
    }

    return ListView.builder(
      itemCount: itinerarios.length,
      itemBuilder: (context, index) {
        final itinerario = itinerarios[index];
        return CheckboxListTile(
          title: Text(itinerario.titulo),
          value: selectedItinerarios[itinerario.id] ?? false,
          onChanged: (bool? selected) {
            setState(() {
              selectedItinerarios[itinerario.id] = selected ?? false;
            });
          },
        );
      },
    );
  }
}
