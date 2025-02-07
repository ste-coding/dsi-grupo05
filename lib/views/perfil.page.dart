import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/controller/auth_controller.dart';
import 'package:flutter_application_1/services/firestore/user.service.dart' as firestore;
import 'package:brasil_fields/brasil_fields.dart';
import 'package:path_provider/path_provider.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String _firstName = '';
  String _email = '';
  String _cpf = '';
  String? _profileImagePath;
  final UserService _userService = UserService();
  final AuthController _authController = AuthController();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  final maskFormatter = UtilBrasilFields.obterCpf;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    var userData = await _userService.getUserData();
    if (userData != null) {
      setState(() {
        _firstName = userData['nome'];
        _email = userData['email'];
        _cpf = maskFormatter(userData['cpf']);
        _profileImagePath = userData['profileImagePath'];
        _firstNameController.text = _firstName;
        _emailController.text = _email;
        _cpfController.text = _cpf;
      });
    }
  }

  Future<void> _saveProfileImage(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/profile_image.png';
      await image.copy(imagePath);
      await _userService.userRef.update({'profileImagePath': imagePath});
      setState(() {
        _profileImagePath = imagePath;
      });
    } catch (e) {
      print('Erro ao salvar imagem de perfil: $e');
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await _authController.signOut();
      await _userService.userRef.delete();
      await FirebaseAuth.instance.currentUser!.delete();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Erro ao excluir conta: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      await _saveProfileImage(file);
    }
  }

  Future<void> _updateUserData() async {
    try {
      await _userService.userRef.update({
        'nome': _firstNameController.text,
        'email': _emailController.text,
        'cpf': _cpfController.text,
      });
      setState(() {
        _firstName = _firstNameController.text;
        _email = _emailController.text;
        _cpf = _cpfController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
    } catch (e) {
      print('Erro ao atualizar dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/menu');
          },
        ),
        title: Text(
          'Meu perfil',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : null,
                    child: _profileImagePath == null
                        ? Icon(Icons.camera_alt, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Color(0xFFD9D9D9).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Color(0xFFD9D9D9).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _cpfController,
                decoration: InputDecoration(
                  labelText: 'CPF',
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Color(0xFFD9D9D9).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF266B70), width: 2),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Cancelar",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Color(0xFF266B70),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _updateUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF266B70),
                      side: BorderSide(color: Color(0xFF266B70), width: 2),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Salvar",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Color(0xFF266B70),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _authController.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF266B70),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
