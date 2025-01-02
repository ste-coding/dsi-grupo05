import 'package:flutter/material.dart';

class CriarItinerarioPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
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
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          itinerarioExistente != null
              ? 'Editar Itinerário'
              : 'Criar Itinerário',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontSize: 32,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color(0xFFDFEAF1),
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
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título da Atividade',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Color(0xFFD9D9D9).withOpacity(0.5),
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
                SizedBox(height: 20),
                TextFormField(
                  controller: _horarioController,
                  decoration: InputDecoration(
                    labelText: 'Horário',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Color(0xFFD9D9D9).withOpacity(0.5),
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
                SizedBox(height: 20),
                TextFormField(
                  controller: _localizacaoController,
                  decoration: InputDecoration(
                    labelText: 'Localização',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Color(0xFFD9D9D9).withOpacity(0.5),
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
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final novoItinerario = {
                        'titulo': _tituloController.text,
                        'horario': _horarioController.text,
                        'localizacao': _localizacaoController.text,
                      };
                      onSalvarItinerario(
                          novoItinerario); // Salva ou atualiza o itinerário
                      Navigator.pop(
                          context); // Volta para a página de itinerários
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF266B70),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text(
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
