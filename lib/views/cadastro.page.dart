import 'package:flutter/material.dart';
import 'package:flutter_application_1/controller/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_application_1/services/firestore/user.service.dart' as firestore;
import 'package:flutter_application_1/services/firestore/user.service.dart';
import 'package:flutter/services.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final AuthController _authController = AuthController();
  final firestore.UserService _userService = firestore.UserService();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  'Cadastre-se',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já Possui uma conta?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Color(0xFF266B70),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildTextFormField(_nomeController, 'Nome completo', false, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome completo';
                  }
                  return null;
                }),
                const SizedBox(height: 30),
                _buildTextFormField(_emailController, 'Email', false, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                }),
                const SizedBox(height: 30),
                _buildTextFormField(_cpfController, 'CPF', false, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu CPF';
                  } else if (!CPFValidator.isValid(value)) {
                    return 'Por favor, insira um CPF válido';
                  }
                  return null;
                }, inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ]),
                const SizedBox(height: 30),
                _buildTextFormField(_passwordController, 'Senha', true, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                }),
                const SizedBox(height: 30),
                _buildTextFormField(_confirmPasswordController, 'Confirmar senha', true, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme sua senha';
                  } else if (value != _passwordController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                }),
                const SizedBox(height: 45),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: OutlinedButton(
                          onPressed: _handleCadastro,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF266B70), width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cadastrar',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              color: Colors.black,
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

  Widget _buildTextFormField(TextEditingController controller, String label, bool isPassword, String? Function(String?) validator, {List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: const Color(0xFFD9D9D9).withOpacity(0.5),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      obscureText: isPassword,
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }

  Future<void> _handleCadastro() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool isCpfRegistered = await _userService.isCpfRegistered(_cpfController.text);
      if (isCpfRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CPF já cadastrado.')),
        );
      } else {
        try {
          User? user = await _authController.registerWithEmailPassword(
            _emailController.text,
            _passwordController.text,
            _cpfController.text,
            _nomeController.text,
          );
            if (user != null) {
            await _userService.createUserDocument(
              user,
              _nomeController.text,
              _cpfController.text,
              null, // profileImage
            );
            Navigator.pushReplacementNamed(context, '/inicial');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Falha no cadastro.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}
