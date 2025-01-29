// lib/views/explore.page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/local_controller.dart';
import '../models/local_model.dart';
import '../widgets/local_card.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocais();
  }

  void _loadLocais() {
  final localController = Provider.of<LocalController>(context, listen: false);
  String searchTerm = _searchController.text.trim();
  String location = '';

  if (searchTerm.isNotEmpty) {
    localController.fetchLocais(searchTerm, location);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explorar Locais'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Pesquisar por locais...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _loadLocais();
                    },
                  ),
                ),
              ),
            ),

            Expanded(
              child: Consumer<LocalController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage != null) {
                    return Center(child: Text(controller.errorMessage!));
                  }

                  if (controller.locais.isEmpty) {
                    return Center(child: Text('Nenhum local encontrado.'));
                  }

                  return ListView.builder(
                    itemCount: controller.locais.length,
                    itemBuilder: (context, index) {
                      final local = controller.locais[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LocalCard(local: local),
                      );
                    },
                  );
                },
              ),
            ),
          ]
        )
      )
    );
  }
}
