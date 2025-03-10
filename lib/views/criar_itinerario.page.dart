import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore/itinerarios.service.dart';
import 'package:flutter_application_1/models/itinerario_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Para conversão de Base64
import 'package:image_picker/image_picker.dart'; // Para pegar a imagem
import 'dart:typed_data'; // Para manipular dados binários
import 'dart:io'; // Para manipular arquivos
import 'package:flutter/foundation.dart'; // Para kIsWeb

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

  Future<String?> _getImageBase64(String imagePath) async {
    // Converte a imagem para Base64
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      return base64Encode(Uint8List.fromList(bytes)); // Converte para base64
    } catch (e) {
      print('Erro ao converter imagem para Base64: $e');
      return null;
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
                _buildImagePicker(),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveItinerario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF266B70),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    child: const Text(
                      'Salvar Itinerário',
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
        labelStyle:
            const TextStyle(color: Color(0xFF266B70), fontFamily: 'Poppins'),
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
      style: const TextStyle(fontFamily: 'Poppins'),
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
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins')),
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
        Text(label,
            style: const TextStyle(
                color: Color(0xFF266B70), fontFamily: 'Poppins')),
        TextButton(
          onPressed: () => _selectDate(context, isStartDate),
          child: Text(
            date == null ? 'Selecione' : DateFormat('dd/MM/yyyy').format(date),
            style: const TextStyle(
                color: Color(0xFF266B70), fontFamily: 'Poppins'),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Escolha uma imagem:',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.memory(
                            base64Decode(_selectedImage!.replaceAll('\n', '')),
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image, size: 150, color: Colors.red);
                            },
                          )
                        : Image.memory(
                            base64Decode(_selectedImage!.replaceAll('\n', '')),
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image, size: 150, color: Colors.red);
                            },
                          ),
                  )
                : Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.grey[600],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      if (mounted) {
        setState(() {
          _selectedImage = base64Encode(bytes).replaceAll('\n', '');
        });
      }
    }
  }

  Future<void> _saveItinerario() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        _selectedImage != null) {
      String? imageBase64 = _selectedImage;

      final itinerario = ItinerarioModel(
        id: DateTime.now().toString(),
        userId: widget.userId,
        titulo: _tituloController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        observations: _observationsController.text,
        imageUrl: imageBase64,
        locais: [],
      );

      await itinerariosService.addItinerario(itinerario.toFirestore());
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}