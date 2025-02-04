import 'package:flutter/material.dart';
import '../models/itinerario_model.dart'; // Certifique-se de que o caminho esteja correto
import 'package:intl/intl.dart';
import '../services/firestore/itinerarios.service.dart'; // Importe o serviço de itinerários

class RoteiroTab extends StatefulWidget {
  final ItinerarioModel itinerario;

  const RoteiroTab({Key? key, required this.itinerario}) : super(key: key);

  @override
  _RoteiroTabState createState() => _RoteiroTabState();
}

class _RoteiroTabState extends State<RoteiroTab> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  final Map<String, bool> _visitedPlaces = {};

  Map<DateTime, List<ItinerarioItem>> _groupedLocais = {};

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ItinerarioModel>(
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
                      bool isWithinItinerary = date.isAfter(
                              itinerario.startDate.subtract(const Duration(days: 1))) &&
                          date.isBefore(
                              itinerario.endDate.add(const Duration(days: 1)));

                      return GestureDetector(
                        onTap: isWithinItinerary
                            ? () => _onDateSelected(date)
                            : null,
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
                                color: isSelected
                                    ? Colors.white
                                    : isWithinItinerary
                                        ? Colors.black
                                        : Colors.grey,
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
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
                      title: Text(DateFormat('dd/MM/yyyy').format(date)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: locais.map((local) {
                          final isVisited = _visitedPlaces[local.localId] ?? false;
                          return ListTile(
                            title: Text(local.localName  ?? 'Nome do local não disponível'),
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
    );
  }

  Future<ItinerarioModel> _loadLocais() async {
    try {
      final itinerarioService = ItinerariosService('userId');
      return await itinerarioService.getItinerarioWithLocais(widget.itinerario.id);
    } catch (e) {
      print("Erro ao carregar locais: $e");
      throw e;
    }
  }
}
