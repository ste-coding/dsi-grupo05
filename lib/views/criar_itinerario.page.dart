import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore/itinerarios.service.dart';
import 'package:flutter_application_1/models/itinerario_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Para conversão de Base64
import 'package:image_picker/image_picker.dart'; // Para pegar a imagem
import 'dart:typed_data'; // Para manipular dados binários
import 'dart:io'; // Para manipular arquivos de imagem

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
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _availableImages.length) {
                return GestureDetector(
                  onTap: _pickImage,
                  child: Card(
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add,
                        size: 60, color: Color(0xFF266B70)),
                  ),
                );
              }
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
                          ? Color(0xFF266B70)
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile.path;
      });
    }
  }

  Future<void> _saveItinerario() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        _selectedImage != null) {
      String? imageBase64; // Agora a variável é String? (pode ser null)

      // Se a imagem for uma imagem do assets, não precisa converter
      if (_selectedImage!.startsWith('assets/')) {
        imageBase64 = _selectedImage;
      } else {
        imageBase64 = await _getImageBase64(_selectedImage!);
        if (imageBase64 == null) {
          // Se a conversão para base64 falhar, você pode lidar com isso aqui
          // Exemplo: atribuir uma imagem padrão ou mostrar um erro
          imageBase64 =
              'assets/images/default_image.jpg'; // ou algum valor padrão
        }
      }

      final itinerario = ItinerarioModel(
        id: DateTime.now().toString(),
        userId: widget.userId,
        titulo: _tituloController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        observations: _observationsController.text,
        imageUrl: imageBase64, // Armazena a imagem Base64 no Firestore
        locais: [],
      );

      await itinerariosService.addItinerario(itinerario.toFirestore());
      Navigator.pop(context);
    }
  }
}