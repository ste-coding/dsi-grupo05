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
  }

  void _loadActivities() async {
    try {
      final fetchedActivities =
          await roteiroService.getActivities(widget.roteiroId);
      print(fetchedActivities); // Verifique o conteúdo aqui
      setState(() {
        for (var activity in fetchedActivities) {
          DateTime activityDate = DateTime.parse(activity['date']);

          // Converte a string de horário para TimeOfDay
          String timeStr = activity['time'];
          List<String> timeParts = timeStr.split(':');
          TimeOfDay activityTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );

          if (activities.containsKey(activityDate)) {
            activities[activityDate]?.add({
              'name': activity['name'],
              'time': activityTime,
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
          setState(() {
            activities[date]?.last['id'] =
                DateTime.now().toString(); // Gerando um ID temporário
          });
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
          roteiroId: widget.roteiroId, // Passando o ID do roteiro
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
      appBar: AppBar(title: const Text("Roteiro de Viagem")),
      body: Column(
        children: [
          // Gerenciamento das datas do itinerário
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
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: selectedDay == day
                          ? const Color(0xFF266B70)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('dd/MM').format(day),
                        style: TextStyle(
                          color:
                              selectedDay == day ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
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
                : Column(
                    children: [
                      ...?activities[selectedDay]?.isEmpty ?? true
                          ? [Text("Nenhuma atividade disponível")]
                          : activities[selectedDay]!
                              .asMap()
                              .entries
                              .map((entry) {
                              int idx = entry.key;
                              Map<String, dynamic> activity = entry.value;
                              return Dismissible(
                                key: Key(activity["name"]),
                                onDismissed: (direction) {
                                  _deleteActivity(selectedDay!, idx);
                                },
                                background: Container(color: Colors.red),
                                child: GestureDetector(
                                  onTap: () => _editActivity(selectedDay!, idx),
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
                                            "Horário: ${activity["time"].format(context)}",
                                            style: TextStyle(
                                                color: Color(0xFF01A897)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                    ],
                  ),
          )
        ],
      ),
      floatingActionButton: selectedDay == null
          ? null
          : FloatingActionButton(
              onPressed: () => _addActivity(selectedDay!),
              backgroundColor: const Color(0xFF266B70),
              child: const Icon(Icons.add, color: Colors.white),
            ),
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
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.activity?["name"] ?? "");
    selectedTime = widget.activity?["time"] ?? TimeOfDay(hour: 9, minute: 0);
  }

  void _saveActivity() {
    if (nameController.text.isNotEmpty) {
      final newActivity = {
        "name": nameController.text,
        "time": selectedTime,
      };

      Navigator.pop(context, newActivity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Atividade")),
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
            Row(
              children: [
                Text("Horário: ${selectedTime.format(context)}"),
                IconButton(
                  icon: Icon(
                    Icons.access_time,
                    color: Color(0xFF01A897),
                  ),
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            primaryColor: Color(0xFF01A897),
                            colorScheme: ColorScheme.light(
                              primary: Color(0xFF01A897),
                              secondary: Color(
                                  0xFF01A897), // Usado no lugar do accentColor
                            ),
                            buttonTheme: ButtonThemeData(
                              textTheme: ButtonTextTheme.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01A897),
                  textStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Salvar Atividade',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
