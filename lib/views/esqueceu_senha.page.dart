// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_application_1/controller/auth_controller.dart';

class SenhaPage extends StatefulWidget {
  const SenhaPage({super.key});

  @override
  State<SenhaPage> createState() => _SenhaPageState();
}

class _SenhaPageState extends State<SenhaPage> {
  final TextEditingController _emailController = TextEditingController();
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 100),
            Text(
              'Esqueceu a senha?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Já possui uma conta?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Color(0xFF266B70)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 80),
            SizedBox(
              width: 300,
              height: 48,
              child: TextFormField(
                controller: _emailController, 
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email de Recuperação',
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Color(0xFFD9D9D9).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 45),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: OutlinedButton(
                onPressed: () async {
                  final email = _emailController.text;
                  try {
                    bool emailExists = await AuthController().isEmailRegistered(email);
                    if (emailExists) {
                      await AuthController().resetPasswordWithEmail(email);
                      setState(() {
                        _statusMessage = 'Email de recuperação enviado!';
                      });
                    } else {
                      setState(() {
                        _statusMessage = 'Erro: Email não cadastrado!';
                      });
                    }
                  } catch (e) {
                    setState(() {
                      _statusMessage = 'Erro ao enviar email!';
                    });
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF266B70), width: 2),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Color(0xFF266B70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Enviar email',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _statusMessage,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}