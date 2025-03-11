import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore/checklist.service.dart';

class ChecklistPage extends StatefulWidget {
  final String itinerarioId;
  final String? docID;
  final String? currentTask;

  const ChecklistPage(
      {super.key, required this.itinerarioId, this.docID, this.currentTask});

  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final TextEditingController _taskController = TextEditingController();
  late ChecklistService _checklistService;

  @override
  void initState() {
    super.initState();
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      throw Exception('Erro: Usuário não autenticado.');
    }
    _checklistService = ChecklistService(userId, widget.itinerarioId);

    if (widget.currentTask != null) {
      _taskController.text = widget.currentTask!;
    }
  }

  void _addTask(String task) async {
    try {
      await _checklistService.addTask({
        'task': task,
        'itinerarioId': widget.itinerarioId,
        'completed': false,
      });
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackbar('Erro ao adicionar tarefa.');
    }
  }

  void _editTask(String docID, String updatedTask) async {
    try {
      await _checklistService.updateTask(docID, updatedTask);
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackbar('Erro ao editar tarefa.');
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
      appBar: AppBar(
        title: Text(
          widget.docID == null ? 'Adicionar Tarefa' : 'Editar Tarefa',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Tarefa',
                hintText: 'Digite o nome da tarefa...',
                labelStyle: const TextStyle(color: Color(0xFF266B70)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF266B70)),
                ),
              ),
              cursorColor: Colors.black,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  onPressed: () {
                    final task = _taskController.text;
                    if (task.isNotEmpty) {
                      if (widget.docID == null) {
                        _addTask(task);
                      } else {
                        _editTask(widget.docID!, task);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF266B70),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.docID == null ? 'Adicionar' : 'Salvar',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
