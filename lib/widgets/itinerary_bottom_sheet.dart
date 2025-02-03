import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../models/itinerario_model.dart';

void showItineraryBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return ItineraryBottomSheet();
    },
  );
}
class ItineraryBottomSheet extends StatefulWidget {
  @override
  _ItineraryBottomSheetState createState() => _ItineraryBottomSheetState();
}

class _ItineraryBottomSheetState extends State<ItineraryBottomSheet> {
  List<ItinerarioModel> itinerarios = [];
  
  Map<String, bool> selectedItinerarios = {};

  @override
  void initState() {
    super.initState();
    _fetchUserItinerarios();
  }

  Future<void> _fetchUserItinerarios() async {
    final itinerariosService = Provider.of<LocalController>(context, listen: false);
    final fetchedItinerarios = await itinerariosService.getUserItinerarios();
    setState(() {
      itinerarios = fetchedItinerarios;

      selectedItinerarios = { 
        for (var itinerario in itinerarios) itinerario.id: false 
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserItinerarios(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
      },
    );
  }
}
