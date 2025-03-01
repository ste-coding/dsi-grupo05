import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore/checklist.service.dart';
import '/views/checklist_page.dart';

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

  void _navigateToTaskPage({String? docID, String? currentTask}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChecklistPage(
          itinerarioId: widget.itinerarioId,
          docID: docID,
          currentTask: currentTask,
        ),
      ),
    );
  }

  void _toggleTaskCompletion(String docID, bool completed) async {
    try {
      await _checklistService.updateTaskStatus(docID, !completed);
    } catch (e) {
      _showErrorSnackbar('Erro ao atualizar status da tarefa.');
    }
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
                            onTap: () => _navigateToTaskPage(
                                docID: taskId, currentTask: taskName),
                            leading: Checkbox(
                              value: completed,
                              onChanged: (value) {
                                _toggleTaskCompletion(taskId, completed);
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
          _navigateToTaskPage(); // Navega para a página de adicionar tarefa
        },
        backgroundColor: const Color(0xFF01A897), // Cor do botão flutuante
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}