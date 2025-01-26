import 'package:flutter/material.dart';

class ChecklistPage extends StatefulWidget {
  final String docID;

  const ChecklistPage({Key? key, required this.docID}) : super(key: key);

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  List<Map<String, dynamic>> _checklist = []; // Lista de itens do checklist

  final TextEditingController _taskController = TextEditingController();

  void _addTask(String task) {
    setState(() {
      _checklist.add({'task': task, 'completed': false});
    });
    _taskController.clear();
    Navigator.of(context).pop();
  }

  void _removeTask(int index) {
    setState(() {
      _checklist.removeAt(index);
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _checklist[index]['completed'] = !_checklist[index]['completed'];
    });
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
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

//função para editar tarefa
  void _showEditTaskDialog(int index) {
    _taskController.text = _checklist[index]['task'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Tarefa'),
        content: TextField(
          controller: _taskController,
          decoration: const InputDecoration(hintText: 'Renomear tarefa'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (_taskController.text.trim().isNotEmpty) {
                _editTask(index, _taskController.text.trim());
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

//função para atualizar a task editada
  void _editTask(int index, String updatedTask) {
    setState(() {
      _checklist[index]['task'] = updatedTask;
    });
    _taskController.clear();
    Navigator.of(context).pop();
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
              child: _checklist.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma tarefa adicionada.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _checklist.length,
                      itemBuilder: (context, index) {
                        final item = _checklist[index];
                        return Dismissible(
                          key: Key(item['task']),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _removeTask(index);
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
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['task'],
                                    style: TextStyle(
                                      decoration: item['completed']
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _showEditTaskDialog(index);
                                  },
                                ),
                              ],
                            ),
                            value: item['completed'],
                            onChanged: (value) {
                              _toggleTaskCompletion(index);
                            },
                          ),
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
