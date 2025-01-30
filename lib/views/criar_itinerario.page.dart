import 'package:flutter/material.dart';

class CriarItinerarioPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController(); // Controller para observações
  final Function(Map<String, String>) onSalvarItinerario;
  final Map<String, String>? itinerarioExistente; // Para editar

  CriarItinerarioPage({
    super.key,
    required this.onSalvarItinerario,
    this.itinerarioExistente,
  });

  @override
  Widget build(BuildContext context) {
    // Preencher os campos com o itinerário existente, caso esteja editando
    if (itinerarioExistente != null) {
      _tituloController.text = itinerarioExistente!['titulo'] ?? '';
      _horarioController.text = itinerarioExistente!['horario'] ?? '';
      _localizacaoController.text = itinerarioExistente!['localizacao'] ?? '';
      _observacoesController.text = itinerarioExistente!['observacoes'] ?? ''; // Preenchendo o campo de observações
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          itinerarioExistente != null
              ? 'Editar Itinerário'
              : 'Criar Itinerário',
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontSize: 32,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFDFEAF1),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  itinerarioExistente != null
                      ? 'Editar Itinerário'
                      : 'Novo Itinerário',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título da Atividade',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome da atividade';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _horarioController,
                  decoration: InputDecoration(
                    labelText: 'Horário',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o horário';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _localizacaoController,
                  decoration: InputDecoration(
                    labelText: 'Localização',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a localização';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Novo campo de Observações
                TextFormField(
                  controller: _observacoesController,
                  decoration: InputDecoration(
                    labelText: 'Observações',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.length > 500) {
                      return 'Observações devem ter no máximo 500 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Incluindo o campo de observações ao salvar ou editar
                      final novoItinerario = {
                        'titulo': _tituloController.text,
                        'horario': _horarioController.text,
                        'localizacao': _localizacaoController.text,
                        'observacoes': _observacoesController.text, // Adicionando observações
                      };
                      onSalvarItinerario(
                          novoItinerario); // Salva ou atualiza o itinerário
                      Navigator.pop(
                          context); // Volta para a página de itinerários
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF266B70),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}