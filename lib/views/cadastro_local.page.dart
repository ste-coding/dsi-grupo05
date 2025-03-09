import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../models/local_user_model.dart';
import '../services/firestore/local_user.service.dart';
import '../views/menu.page.dart';

class CadastroLocalPage extends StatefulWidget {
  final LocalUserModel? local;

  CadastroLocalPage({this.local});

  @override
  _CadastroLocalPageState createState() => _CadastroLocalPageState();
}

class _CadastroLocalPageState extends State<CadastroLocalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final LocalUserService _localService = LocalUserService();
  final _uuid = Uuid();

  String? _imagemBase64;

  @override
  void initState() {
    super.initState();
    if (widget.local != null) {
      _nomeController.text = widget.local!.nome;
      _descricaoController.text = widget.local!.descricao;
      _categoriaController.text = widget.local!.categoria;
      _logradouroController.text = widget.local!.logradouro;
      _numeroController.text = widget.local!.numero;
      _bairroController.text = widget.local!.bairro;
      _cidadeController.text = widget.local!.cidade;
      _estadoController.text = widget.local!.estado;
      _latitudeController.text = widget.local!.latitude.toString();
      _longitudeController.text = widget.local!.longitude.toString();
      _imagemBase64 = widget.local!.imagem;
    }
  }

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imagemBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _preencherCoordenadas() async {
    final endereco = '${_logradouroController.text}, ${_numeroController.text}, ${_bairroController.text}, ${_cidadeController.text}, ${_estadoController.text}';
    try {
      final coordenadas = await getLatLongFromAddress(endereco);
      setState(() {
        _latitudeController.text = coordenadas['latitude'].toString();
        _longitudeController.text = coordenadas['longitude'].toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar coordenadas: $e')),
      );
    }
  }

  Future<Map<String, double>> getLatLongFromAddress(String address) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$address');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return {'latitude': lat, 'longitude': lon};
      }
    }
    throw Exception('Não foi possível obter as coordenadas para o endereço fornecido.');
  }

  Future<void> _salvarLocal() async {
    if (_formKey.currentState!.validate()) {
      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) {
        print("❌ Usuário não autenticado.");
        return;
      }

      try {
        double latitude = _latitudeController.text.isNotEmpty ? double.parse(_latitudeController.text) : 0.0;
        double longitude = _longitudeController.text.isNotEmpty ? double.parse(_longitudeController.text) : 0.0;

        final local = LocalUserModel(
          id: widget.local?.id ?? _uuid.v4(),
          nome: _nomeController.text,
          descricao: _descricaoController.text,
          imagem: _imagemBase64 ?? '',
          categoria: _categoriaController.text,
          logradouro: _logradouroController.text,
          numero: _numeroController.text,
          bairro: _bairroController.text,
          cidade: _cidadeController.text,
          estado: _estadoController.text,
          latitude: latitude,
          longitude: longitude,
          usuarioId: usuario.uid,
          dataCriacao: DateTime.now(),
        );

        print("📌 Salvando local: ${local.toJson()}");

        if (widget.local == null) {
          await _localService.addLocal(local);
        } else {
          await _localService.updateLocal(local);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Local salvo com sucesso!'))
        );

        await Future.delayed(Duration(milliseconds: 500));

        setState(() {}); 

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MenuPage()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        print("❌ Erro ao salvar local: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro ao salvar local: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.local == null ? 'Cadastrar Novo Local' : 'Editar Local',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _selecionarImagem,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(_nomeController, "Nome"),
                SizedBox(height: 16),
                _buildTextField(_descricaoController, "Descrição"),
                SizedBox(height: 16),
                _buildTextField(_categoriaController, "Categoria"),
                SizedBox(height: 16),
                _buildTextField(_logradouroController, "Logradouro"),
                SizedBox(height: 16),
                _buildTextField(_numeroController, "Número"),
                SizedBox(height: 16),
                _buildTextField(_bairroController, "Bairro"),
                SizedBox(height: 16),
                _buildTextField(_cidadeController, "Cidade"),
                SizedBox(height: 16),
                _buildTextField(_estadoController, "Estado"),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _preencherCoordenadas,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF266B70),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontFamily: 'Poppins'),
                  ),
                  child: const Text(
                    'Preencher Coordenadas',
                    style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                _buildTextField(_latitudeController, "Latitude", keyboardType: TextInputType.number),
                SizedBox(height: 16),
                _buildTextField(_longitudeController, "Longitude", keyboardType: TextInputType.number),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _salvarLocal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF266B70),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontFamily: 'Poppins'),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        widget.local == null ? "Salvar Local" : "Atualizar Local",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontFamily: 'Poppins'),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: TextStyle(fontFamily: 'Poppins'),
    );
  }
}