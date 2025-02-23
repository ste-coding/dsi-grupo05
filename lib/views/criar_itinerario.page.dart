import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore/itinerarios.service.dart';
import 'package:flutter_application_1/models/itinerario_model.dart';
import 'package:intl/intl.dart';

class CreateItinerarioPage extends StatefulWidget {
  final String userId;

  const CreateItinerarioPage({super.key, required this.userId});

  @override
  _CreateItinerarioPageState createState() => _CreateItinerarioPageState();
}

class _CreateItinerarioPageState extends State<CreateItinerarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _observationsController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  late ItinerariosService itinerariosService;
  String? _selectedImage;

  final List<String> _availableImages = [
    'assets/images/inverno.jpg',
    'assets/images/acampamento.jpg',
    'assets/images/festivais.jpg',
    'assets/images/cidades_antigas.jpg',
    'assets/images/praia.jpg',
    'assets/images/por_do_sol.jpg',
    'assets/images/trabalho.jpg',
    'assets/images/trilha.jpg',
  ];

  @override
  void initState() {
    super.initState();
    itinerariosService = ItinerariosService(widget.userId);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primaryColor: const Color(0xFF266B70),
            colorScheme: ColorScheme.light(primary: const Color(0xFF266B70)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criar Itinerário',
          style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_tituloController, 'Título', true),
                const SizedBox(height: 16),
                _buildTextField(_observationsController, 'Observações', false),
                const SizedBox(height: 16),
                _buildDateSelection(),
                const SizedBox(height: 16),
                _buildImageSelection(),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveItinerario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF266B70),
                      textStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Salvar Atividade',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
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

  Widget _buildTextField(
      TextEditingController controller, String label, bool isRequired) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF266B70)),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: isRequired
          ? (value) =>
              value == null || value.isEmpty ? 'Insira um $label' : null
          : null,
    );
  }

  Widget _buildDateSelection() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Selecione as Datas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDateButton('Data de Início', _startDate, true),
                _buildDateButton('Data de Fim', _endDate, false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, bool isStartDate) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF266B70))),
        TextButton(
          onPressed: () => _selectDate(context, isStartDate),
          child: Text(
            date == null ? 'Selecione' : DateFormat('dd/MM/yyyy').format(date),
            style: const TextStyle(color: Color(0xFF266B70)),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Escolha uma imagem:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 120, // Altura ajustada para acomodar melhor as imagens
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableImages.length,
            itemBuilder: (context, index) {
              final image = _availableImages[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImage = image;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedImage == image
                          ? Colors.blue
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(image, fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _saveItinerario() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        _selectedImage != null) {
      final itinerario = ItinerarioModel(
        id: '',
        userId: widget.userId,
        titulo: _tituloController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        observations: _observationsController.text,
        imageUrl: _selectedImage!,
        locais: [],
      );
      await itinerariosService.addItinerario(itinerario.toFirestore());
      Navigator.pop(context);
    }
  }
}
