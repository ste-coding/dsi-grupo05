// ignore_for_file: use_key_in_widget_constructors, unused_import, duplicate_import

import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/checklist.page.dart';
import 'package:flutter_application_1/views/favoritos.page.dart';
import 'package:flutter_application_1/views/itinerario.page.dart';
import 'package:flutter_application_1/views/login.page.dart';
import 'package:flutter_application_1/views/cadastro.page.dart';
import 'package:flutter_application_1/views/inicial.page.dart';
import 'package:flutter_application_1/views/menu.page.dart';
import 'package:flutter_application_1/views/redefinir_senha.page.dart';
import 'package:flutter_application_1/views/esqueceu_senha.page.dart';
import 'package:flutter_application_1/views/checklist.page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'boraLa',
      debugShowCheckedModeBanner: false,
      initialRoute: '/inicial',
      routes: {
        '/menu': (context) => MenuPage(),
        '/inicial': (context) => InicialPage(),
        '/login': (context) => LoginPage(),
        '/cadastro': (context) => CadastroPage(),
        '/redefinir': (context) => RedefinirPage(),
        '/senha': (context) => SenhaPage(),
        '/itinerario': (context) => ItinerarioPage(),
        '/favoritos': (context) => FavoritosPage(),
        '/checklist': (context) => ChecklistPage(
              docID: '',
            ),
      },
    );
  }
}
