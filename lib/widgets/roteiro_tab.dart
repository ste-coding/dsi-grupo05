import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/services/firestore/roteiro.service.dart';

class RoteiroPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String roteiroId; // Adicionado para salvar/atualizar/excluir atividades

  const RoteiroPage({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.roteiroId, // Recebendo o ID do roteiro
  });

  @override
  _RoteiroPageState createState() => _RoteiroPageState();
}

class _RoteiroPageState extends State<RoteiroPage> {
  late List<DateTime> travelDays;
  Map<DateTime, List<Map<String, dynamic>>> activities = {};
  DateTime? selectedDay;
  late RoteiroService roteiroService;

  @override
  void initState() {
    super.initState();
    roteiroService = RoteiroService();
    travelDays = List.generate(
      widget.endDate.difference(widget.startDate).inDays + 1,
      (index) => widget.startDate.add(Duration(days: index)),
    );
    // Inicializa o mapa de atividades
    for (var day in travelDays) {
      activities[day] = [];
    }
    _loadActivities(); // Carregar atividades do Firestore

    // Seleciona a primeira data ao inicializar
    selectedDay = travelDays.first;
  }

  void _loadActivities() async {
    try {
      final fetchedActivities =
          await roteiroService.getActivities(widget.roteiroId);
      setState(() {
        for (var activity in fetchedActivities) {
          DateTime activityDate = DateTime.parse(activity['date']).toLocal();

          if (activities.containsKey(activityDate)) {
            activities[activityDate]?.add({
              'name': activity['name'],
              'time': activity['time'], // A hora agora é uma string
              'id': activity['id'],
            });
          }
        }
      });
    } catch (e) {
      print('Erro ao carregar atividades: $e');
    }
  }

  void _addActivity(DateTime date) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateActivityPage(
          date: date,
          roteiroId: widget.roteiroId,
        ),
      ),
    ).then((newActivity) async {
      if (newActivity != null) {
        setState(() {
          activities[date]?.add(newActivity);
        });

        try {
          await roteiroService.saveActivities(
            widget.roteiroId,
            date,
            [newActivity], // Salvar a nova atividade
          );
        } catch (e) {
          print('Erro ao salvar a atividade: $e');
        }
      }
    });
  }

  void _editActivity(DateTime date, int index) async {
    final activity = activities[date]?[index];
    if (activity == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateActivityPage(
          date: date,
          roteiroId: widget.roteiroId,
          activityIndex: index,
          activity: activity,
        ),
      ),
    ).then((updatedActivity) {
      if (updatedActivity != null) {
        setState(() {
          activities[date]?[index] = updatedActivity;
        });
        // Atualizar no Firestore
        roteiroService.updateActivity(
            widget.roteiroId, activity['id'], updatedActivity);
      }
    });
  }

  // Método para excluir uma atividade
  void _deleteActivity(DateTime date, int index) async {
    final activity = activities[date]?[index];
    if (activity == null) return;

    setState(() {
      activities[date]?.removeAt(index);
    });
    // Excluir no Firestore
    roteiroService.deleteActivity(widget.roteiroId, activity['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: travelDays.length,
              itemBuilder: (context, index) {
                DateTime day = travelDays[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDay = day;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: selectedDay == day
                          ? const Color(0xFF266B70)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('dd/MM').format(day), // Exibe a data
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: selectedDay == null
                ? Center(child: Text("Selecione uma data"))
                : ListView.builder(
                    itemCount: activities[selectedDay]?.length ?? 0,
                    itemBuilder: (context, index) {
                      final activity = activities[selectedDay]![index];
                      return Dismissible(
                        key: Key(activity["name"]),
                        onDismissed: (direction) {
                          _deleteActivity(selectedDay!, index);
                        },
                        background: Container(color: Colors.red),
                        child: GestureDetector(
                          onTap: () => _editActivity(selectedDay!, index),
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(activity["name"] ?? ""),
                                  Text(
                                    "Horário: ${activity["time"]}",
                                    style: TextStyle(color: Color(0xFF266B70)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: selectedDay == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () => _addActivity(selectedDay!),
                backgroundColor: const Color(0xFF01A897),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class CreateActivityPage extends StatefulWidget {
  final DateTime date;
  final String roteiroId; // Recebendo o ID do roteiro
  final int? activityIndex;
  final Map<String, dynamic>? activity;

  const CreateActivityPage({
    super.key,
    required this.date,
    required this.roteiroId, // Passando o ID do roteiro
    this.activityIndex,
    this.activity,
  });

  @override
  _CreateActivityPageState createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  late TextEditingController nameController;
  late TextEditingController timeController; // Controlador para o horário

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.activity?["name"] ?? "");
    timeController = TextEditingController(
        text: widget.activity?["time"] ?? "09:00"); // Valor default
  }

  void _saveActivity() {
    if (nameController.text.isNotEmpty && timeController.text.isNotEmpty) {
      final newActivity = {
        "name": nameController.text,
        "time": timeController.text, // Agora o horário é uma string
      };

      // Se estiver editando, atualizará a atividade
      if (widget.activityIndex == null) {
        Navigator.pop(context, newActivity); // Criar nova atividade
      } else {
        // Caso contrário, faz a atualização
        Navigator.pop(context, {
          'updated': true,
          'activity': newActivity, // Atualizar a atividade
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.activityIndex == null ? "Criar Atividade" : "Editar Atividade",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 24,
            ),
        ),
        centerTitle: true, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome da Atividade',
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
                  ? 'Insira um nome para a atividade'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: timeController, // Campo de horário
              decoration: InputDecoration(
                labelText: 'Horário (HH:mm)',
                labelStyle: const TextStyle(color: Color(0xFF266B70)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              cursorColor: Colors.black,
              keyboardType:
                  TextInputType.datetime, // Permite entrada de horário
              validator: (value) {
                // Validação simples para garantir o formato correto
                if (value == null ||
                    value.isEmpty ||
                    !RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                  return 'Insira o horário no formato HH:mm';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF266B70), width: 2),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Color(0xFF266B70),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF266B70),
                  textStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.activityIndex == null ? 'Adicionar' : 'Salvar',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
