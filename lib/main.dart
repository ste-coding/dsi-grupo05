import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login.page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'boraLa',
      home: LoginPage(),
    );
  }
}
