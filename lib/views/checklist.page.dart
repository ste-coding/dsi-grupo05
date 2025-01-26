import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore.dart';

class ChecklistPage extends StatefulWidget {
  final String docID;

  const ChecklistPage({Key? key, required this.docID}) : super(key: key);

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final TextEditingController _taskController = TextEditingController();

  void _addTask(String task) {
    FirestoreService().addTask(task);
    _taskController.clear();
  }

  void _removeTask(String docID) {
    FirestoreService().deleteTask(docID);
  }

  void _toggleTaskCompletion(String docID, bool completed) {
    FirestoreService().updateTaskStatus(docID, !completed);
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
              if (_taskController.text.trim().isNotEmpty) {
                _addTask(_taskController.text.trim());
              }
              Navigator.of(context).pop();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
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
                stream: FirestoreService().getChecklistStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar dados.'));
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
