import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/itinerario_model.dart';
import 'package:intl/intl.dart';
import '../services/firestore/itinerarios.service.dart';
import '../controller/local_controller.dart';
import '../models/local_model.dart';

class RoteiroTab extends StatefulWidget {
  final ItinerarioModel itinerario;

  const RoteiroTab({super.key, required this.itinerario});

  @override
  _RoteiroTabState createState() => _RoteiroTabState();
}

class _RoteiroTabState extends State<RoteiroTab> {
  late DateTime _selectedDate;
  final Map<DateTime, List<ItinerarioItem>> _groupedLocais = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.itinerario.startDate;
    _groupLocaisByDate();
  }

  void _groupLocaisByDate() {
    _groupedLocais.clear();
    for (var local in widget.itinerario.locais) {
      final date = DateUtils.dateOnly(local.visitDate);
      if (!_groupedLocais.containsKey(date)) {
        _groupedLocais[date] = [];
      }
      _groupedLocais[date]!.add(local);
    }
  }

  void _navigateToAddActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelecionarLocalScreen()),
    );
  }

  void _removeLocal(DateTime date, ItinerarioItem local) {
    setState(() {
      _groupedLocais[date]?.remove(local);
      if (_groupedLocais[date]?.isEmpty ?? false) {
        _groupedLocais.remove(date);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Roteiro do Itinerário',
          style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _groupedLocais.keys.length,
        itemBuilder: (context, index) {
          final date = _groupedLocais.keys.toList()[index];
          final locais = _groupedLocais[date]!;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(date),
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: locais
                        .map((local) => Dismissible(
                              key: Key(local.localId),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                _removeLocal(date, local);
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                color: Colors.red,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Colors.teal),
                                title: Text(
                                    local.localName ?? 'Nome não disponível'),
                                subtitle:
                                    Text(local.comment ?? 'Sem comentário'),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddActivity,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class SelecionarLocalScreen extends StatefulWidget {
  const SelecionarLocalScreen({super.key});

  @override
  _SelecionarLocalScreenState createState() => _SelecionarLocalScreenState();
}

class _SelecionarLocalScreenState extends State<SelecionarLocalScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<LocalController>(context, listen: false)
        .fetchLocais('', 'Brasil');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Local')),
      body: Consumer<LocalController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
                  if (controller.featuredLocations.isEmpty) {
                    return const Center(
                      child: Text('Nenhum local encontrado.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.featuredLocations.length,
                    itemBuilder: (context, index) {
                      final local = controller.featuredLocations[index];

              return ListTile(
                leading: const Icon(Icons.place, color: Colors.teal),
                title: Text(local.nome),
                subtitle: Text(local.estado ?? 'estado não disponível'),
                onTap: () {
                  Navigator.pop(context, local);
                },
              );
            },
          );
        },
      ),
    );
  }
}
