import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
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
            fontFamily: 'Poppins', // Fonte Poppins
            fontWeight: FontWeight.bold, // Negrito
            fontSize: 24, // Tamanho 24
            color: Colors.black, // Cor preta
          ),
        ),
        backgroundColor: Colors.transparent, // Fundo transparente
        elevation: 0, // Sem sombra
        centerTitle: true, // Título centralizado
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Ícone preto
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
                    child: _imagemBase64 != null && _imagemBase64!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              base64Decode(_imagemBase64!),
                              height: 150,
                              fit: BoxFit.cover,
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
                SizedBox(height: 20),
                _buildTextField(_nomeController, "Nome"),
                SizedBox(height: 16),
                _buildTextField(_descricaoController, "Descrição"),
                SizedBox(height: 16),
                _buildTextField(_categoriaController, "Categoria"),
                SizedBox(height: 16),
                _buildTextField(_cidadeController, "Cidade"),
                SizedBox(height: 16),
                _buildTextField(_estadoController, "Estado"),
                SizedBox(height: 16),
                _buildTextField(_latitudeController, "Latitude", keyboardType: TextInputType.number),
                SizedBox(height: 16),
                _buildTextField(_longitudeController, "Longitude", keyboardType: TextInputType.number),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _salvarLocal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF266B70), // Cor verde água
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
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
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}