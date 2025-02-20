import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore/checklist.service.dart';

class ChecklistTab extends StatefulWidget {
  final String itinerarioId;

  const ChecklistTab({super.key, required this.itinerarioId});

  @override
  _ChecklistTabState createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<ChecklistTab> {
  late ChecklistService _checklistService;

  @override
  void initState() {
    super.initState();
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      throw Exception('Erro: Usuário não autenticado.');
    }
    _checklistService = ChecklistService(userId, widget.itinerarioId);
  }

  void _navigateToAddEditTaskScreen({String? docID, String? currentTask}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(
          docID: docID,
          currentTask: currentTask,
          checklistService: _checklistService,
          itinerarioId: widget.itinerarioId,
        ),
      ),
    );
  }

  void _removeTask(String docID) async {
    try {
      await _checklistService.deleteTask(docID);
    } catch (e) {
      _showErrorSnackbar('Erro ao excluir tarefa.');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(fontFamily: 'Poppins'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 8),
              Text(
                'Gerencie os itens da sua viagem.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _checklistService.getChecklistStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro ao carregar dados: ${snapshot.error}',
                          style: const TextStyle(
                              color: Colors.red, fontFamily: 'Poppins'),
                        ),
                      );
                    }

                    final tasks = snapshot.data?.docs ?? [];

                    if (tasks.isEmpty) {
                      return Center(
                        child: Text(
                          'Nenhuma tarefa adicionada.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final taskData = task.data() as Map<String, dynamic>;
                        final taskId = task.id;
                        final completed = taskData['completed'];
                        final taskName = taskData['task'];

                        return Dismissible(
                          key: Key(taskId),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _removeTask(taskId);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          child: ListTile(
                            onTap: () => _navigateToAddEditTaskScreen(
                                docID: taskId, currentTask: taskName),
                            leading: Checkbox(
                              value: completed,
                              onChanged: (value) {
                                _checklistService.updateTaskStatus(
                                    taskId, !completed);
                              },
                              activeColor:
                                  Color(0xFF266B70), // Cor da caixa de seleção
                            ),
                            title: Text(
                              taskName,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddEditTaskScreen(); // Navega para a tela de adicionar tarefa
        },
        backgroundColor: const Color(0xFF01A897), // Cor do botão flutuante
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddEditTaskScreen extends StatefulWidget {
  final String? docID;
  final String? currentTask;
  final ChecklistService checklistService;
  final String itinerarioId;

  const AddEditTaskScreen({
    Key? key,
    required this.checklistService,
    required this.itinerarioId,
    this.docID,
    this.currentTask,
  }) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentTask != null) {
      _taskController.text = widget.currentTask!;
    }
  }

  void _saveTask() async {
    final task = _taskController.text.trim();
    if (task.isEmpty) return;

    if (widget.docID == null) {
      await widget.checklistService.addTask({
        'task': task,
        'itinerarioId': widget.itinerarioId,
        'completed': false,
      });
    } else {
      await widget.checklistService.updateTask(widget.docID!, task);
    }

    Navigator.pop(context); // Retorna à tela anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.docID == null ? 'Adicionar Tarefa' : 'Editar Tarefa'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Tarefa',
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF266B70),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              child: ElevatedButton(
                onPressed: _saveTask,
                child: Text(
                  widget.docID == null ? 'Adicionar' : 'Salvar',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF266B70),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
