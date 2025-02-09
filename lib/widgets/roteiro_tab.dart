import 'package:flutter/material.dart';
import '../models/itinerario_model.dart';
import 'package:intl/intl.dart';
import '../services/firestore/itinerarios.service.dart';

class RoteiroTab extends StatefulWidget {
  final ItinerarioModel itinerario;

  const RoteiroTab({super.key, required this.itinerario});

  @override
  _RoteiroTabState createState() => _RoteiroTabState();
}

class _RoteiroTabState extends State<RoteiroTab> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  final Map<String, bool> _visitedPlaces = {};
  final Map<DateTime, List<ItinerarioItem>> _groupedLocais = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.itinerario.startDate;
    _updateWeekDays();
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

  void _updateWeekDays() {
    DateTime startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday % 7),
    );

    _weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _toggleVisited(String localId) {
    setState(() {
      _visitedPlaces[localId] = !(_visitedPlaces[localId] ?? false);
    });
  }

  void _addNewLocal() async {
    final itinerarioService = ItinerariosService('userId');
    final newLocal = ItinerarioItem(
      localId: 'local_123',
      localName: 'Novo Local',
      visitDate: _selectedDate,
      comment: 'Comentário do local',
      itinerarioId: widget.itinerario.id,
    );

    try {
      await itinerarioService.addLocalToRoteiro(widget.itinerario.id, newLocal.toFirestore());
      setState(() {
        widget.itinerario.locais.add(newLocal);
        _groupLocaisByDate();
      });
    } catch (e) {
      print("Erro ao adicionar local: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Roteiro do Itinerário',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<ItinerarioModel>(
        future: _loadLocais(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Erro ao carregar os dados: ${snapshot.error}");
            return Center(child: Text('Erro ao carregar os dados: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Nenhum dado encontrado.'));
          }

          final itinerario = snapshot.data!;
          _groupLocaisByDate();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {
                                setState(() {
                                  _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                                  _updateWeekDays();
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                setState(() {
                                  _selectedDate = _selectedDate.add(const Duration(days: 7));
                                  _updateWeekDays();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                          .map((day) => Text(
                                day,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _weekDays.map((date) {
                        bool isSelected = DateUtils.isSameDay(date, _selectedDate);
                        return GestureDetector(
                          onTap: () => _onDateSelected(date),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor : null,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _groupedLocais.keys.length,
                  itemBuilder: (context, index) {
                    final date = _groupedLocais.keys.toList()[index];
                    final locais = _groupedLocais[date]!;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          DateFormat('dd/MM/yyyy').format(date),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: locais.map((local) {
                            final isVisited = _visitedPlaces[local.localId] ?? false;
                            return ListTile(
                              title: Text(
                                local.localName ?? 'Nome do local não disponível',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              subtitle: Text(
                                local.comment,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isVisited ? Icons.check_circle : Icons.check_circle_outline,
                                  color: isVisited ? Colors.green : null,
                                ),
                                onPressed: () {
                                  _toggleVisited(local.localId);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewLocal,
        tooltip: 'Adicionar Local',
        backgroundColor: Color(0xFF266B70),
        child: const Icon(Icons.add, color: Colors.white),
      ),
        );
      }

  Future<ItinerarioModel> _loadLocais() async {
    try {
      final itinerarioService = ItinerariosService('userId');
      return await itinerarioService.getItinerarioWithLocais(widget.itinerario.id);
    } catch (e) {
      print("Erro ao carregar locais: $e");
      rethrow;
    }
  }
}
