import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login.page.dart';
import 'package:flutter_application_1/pages/cadastro.page.dart';
import 'package:flutter_application_1/pages/inicial.page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'boraLa',
      debugShowCheckedModeBanner: false,
      initialRoute: '/inicial',
      routes: {
        '/inicial': (context) => InicialPage(),
        '/login': (context) => LoginPage(),
        '/cadastro': (context) => CadastroPage(),
      },
    );
  }
}
