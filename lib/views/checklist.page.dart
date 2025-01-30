import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore/checklist.service.dart';

class ChecklistPage extends StatefulWidget {
  final String docID;

  const ChecklistPage({super.key, required this.docID});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final TextEditingController _taskController = TextEditingController();
  late final ChecklistService _checklistService;

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
      await _checklistService.addTask({'task': task});
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

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Tarefa'),
        content: TextField(
          controller: _taskController,
          decoration: const InputDecoration(
            hintText: 'Digite o nome da tarefa',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final taskName = _taskController.text.trim();
              if (taskName.isNotEmpty) {
                _addTask(taskName);
                Navigator.of(context).pop();
              } else {
                _showErrorSnackbar('O nome da tarefa não pode ser vazio.');
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFEAF1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/menu', (route) => false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            const Text(
              'Checklist',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gerencie os itens da sua viagem.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'Itens do Checklist',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
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
                        style: const TextStyle(color: Colors.red),
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
                        child: CheckboxListTile(
                          title: Text(
                            taskData['task'],
                            style: TextStyle(
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          value: completed,
                          onChanged: (value) {
                            _toggleTaskCompletion(taskId, completed);
                          },
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF266B70),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
