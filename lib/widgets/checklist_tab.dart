import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore/checklist.service.dart';

class ChecklistTab extends StatefulWidget {
  final String itinerarioId;

  const ChecklistTab({Key? key, required this.itinerarioId}) : super(key: key);

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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Tarefa'),
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
              final updatedTask = _taskController.text.trim();
              if (updatedTask.isNotEmpty) {
                _checklistService.updateTask(docID, updatedTask);
                Navigator.of(context).pop();
              } else {
                _showErrorSnackbar('O nome da tarefa não pode ser vazio.');
              }
            },
            child: const Text('Salvar'),
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

  void _showAddTaskDialog() {
    _taskController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Checklist',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 30),
                onPressed: _showAddTaskDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Gerencie os itens da sua viagem.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.grey[600],
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
    );
  }
}
