import 'package:flutter/material.dart';
import '../models/itinerario_model.dart';
import 'package:intl/intl.dart';

class RoteiroTab extends StatefulWidget {
  final ItinerarioModel itinerario;

  const RoteiroTab({
    Key? key,
    required this.itinerario,
  }) : super(key: key);

  @override
  _RoteiroTabState createState() => _RoteiroTabState();
}

class _RoteiroTabState extends State<RoteiroTab> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  final Map<String, bool> _visitedPlaces = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.itinerario.startDate;
    _updateWeekDays();
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

  List<ItinerarioItem> _getLocaisForDate(DateTime date) {
    return widget.itinerario.locais.where((local) {
      return DateUtils.isSameDay(local.visitDate, date);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                          widget.itinerario.startDate.subtract(const Duration(days: 1))) &&
                      date.isBefore(
                          widget.itinerario.endDate.add(const Duration(days: 1)));

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
            itemCount: _getLocaisForDate(_selectedDate).length,
            itemBuilder: (context, index) {
              final local = _getLocaisForDate(_selectedDate)[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      local.localName ?? 'https://via.placeholder.com/50',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(local.localName ?? 'Local não especificado'),
                  subtitle: Text(
                    DateFormat('HH:mm').format(local.visitDate),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _visitedPlaces[local.localId] ?? false
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: _visitedPlaces[local.localId] ?? false
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onPressed: () => _toggleVisited(local.localId),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
