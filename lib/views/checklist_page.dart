import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/checklist_tab.dart';

class ChecklistPage extends StatelessWidget {
  final String itinerarioId;

  const ChecklistPage({super.key, required this.itinerarioId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checklist',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ChecklistTab(itinerarioId: itinerarioId),
    );
  }
}
