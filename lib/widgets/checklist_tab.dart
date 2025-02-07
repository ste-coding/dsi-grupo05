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
  final TextEditingController _taskController = TextEditingController();
  late ChecklistService _checklistService;

  @override
  void initState() {
    super.initState();
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      throw Exception('Erro: Usuário não autenticado.');
    }
    _checklistService = ChecklistService(userId);
  }

  void _addTask(String task) async {
    try {
      await _checklistService.addTask({
        'task': task,
        'itinerarioId': widget.itinerarioId,
        'completed': false,
      });
      _taskController.clear();
    } catch (e) {
      _showErrorSnackbar('Erro ao adicionar tarefa.');
    }
  }

  void _removeTask(String docID) async {
    try {
      await _checklistService.deleteTask(docID);
    } catch (e) {
      _showErrorSnackbar('Erro ao excluir tarefa.');
    }
  }

  void _toggleTaskCompletion(String docID, bool completed) async {
    try {
      await _checklistService.updateTaskStatus(docID, !completed);
    } catch (e) {
      _showErrorSnackbar('Erro ao atualizar status da tarefa.');
    }
  }

  void _editTask(String docID, String currentTask) {
    _taskController.text = currentTask;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskPage(
          docID: docID,
          currentTask: currentTask,
          checklistService: _checklistService,
        ),
      ),
    );
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
              const Text(
                'Checklist',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
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
                          style: const TextStyle(color: Colors.red, fontFamily: 'Poppins'),
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
                            leading: Checkbox(
                              value: completed,
                              onChanged: (value) {
                                _toggleTaskCompletion(taskId, completed);
                              },
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
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editTask(taskId, taskName),
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddTaskPage(
                checklistService: _checklistService,
                itinerarioId: widget.itinerarioId,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF266B70),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddTaskPage extends StatelessWidget {
  final ChecklistService checklistService;
  final String itinerarioId;
  final TextEditingController _taskController = TextEditingController();

  AddTaskPage({required this.checklistService, required this.itinerarioId});

  void _addTask(BuildContext context) async {
    final taskName = _taskController.text.trim();
    if (taskName.isNotEmpty) {
      try {
        await checklistService.addTask({
          'task': taskName,
          'itinerarioId': itinerarioId,
          'completed': false,
        });
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar tarefa.', style: TextStyle(fontFamily: 'Poppins'))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O nome da tarefa não pode ser vazio.', style: TextStyle(fontFamily: 'Poppins'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Tarefa', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Digite o nome da tarefa',
                hintStyle: const TextStyle(fontFamily: 'Poppins'),
                filled: true,
                fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addTask(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF266B70),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Salvar', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskPage extends StatelessWidget {
  final String docID;
  final String currentTask;
  final ChecklistService checklistService;
  final TextEditingController _taskController = TextEditingController();

  EditTaskPage({required this.docID, required this.currentTask, required this.checklistService}) {
    _taskController.text = currentTask;
  }

  void _editTask(BuildContext context) async {
    final updatedTask = _taskController.text.trim();
    if (updatedTask.isNotEmpty) {
      try {
        await checklistService.updateTask(docID, updatedTask);
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar tarefa.', style: TextStyle(fontFamily: 'Poppins'))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O nome da tarefa não pode ser vazio.', style: TextStyle(fontFamily: 'Poppins'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarefa', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Digite o nome da tarefa',
                hintStyle: const TextStyle(fontFamily: 'Poppins'),
                filled: true,
                fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _editTask(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF266B70),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Salvar', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }
}
