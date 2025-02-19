import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/favoritos.page.dart';
import 'package:flutter_application_1/views/itinerario.page.dart';
import 'package:flutter_application_1/views/login.page.dart';
import 'package:flutter_application_1/views/cadastro.page.dart';
import 'package:flutter_application_1/views/inicial.page.dart';
import 'package:flutter_application_1/views/menu.page.dart';
import 'package:flutter_application_1/views/open_street_map.page.dart';
import 'package:flutter_application_1/views/redefinir_senha.page.dart';
import 'package:flutter_application_1/views/esqueceu_senha.page.dart';

import 'package:flutter_application_1/controller/menu_controller.dart'
    as custom_menu;
import 'package:flutter_application_1/controller/local_controller.dart';
import 'package:flutter_application_1/repositories/local_repository.dart';
import 'package:flutter_application_1/services/foursquare_service.dart';
import 'package:flutter_application_1/services/firestore/favoritos.service.dart';
import 'package:flutter_application_1/services/firestore/itinerarios.service.dart';
import 'package:flutter_application_1/views/perfil.page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/firestore/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => custom_menu.MenuController()),
        ChangeNotifierProvider(
          create: (_) {
            final userId = FirebaseAuth.instance.currentUser?.uid;
            if (userId == null) {
              print("Erro: Usuário não autenticado.");
            }
            return LocalController(
              LocalRepository(FoursquareService()),
              FavoritosService(userId ?? ""),
              ItinerariosService(userId ?? ""),
            );
          },
        ),
        Provider(create: (_) {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            print("Erro: Usuário não autenticado.");
          }
          return FavoritosService(userId ?? "");
        }),
        Provider(create: (_) {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            print("Erro: Usuário não autenticado.");
          }
          return ItinerariosService(userId ?? "");
        }),
        Provider(create: (_) => UserService()),
      ],
      child: MaterialApp(
        title: 'boraLa',
        debugShowCheckedModeBanner: false,
        initialRoute: '/inicial',
        routes: {
          '/menu': (context) => const MenuPage(),
          '/inicial': (context) => const InicialPage(),
          '/login': (context) => const LoginPage(),
          '/cadastro': (context) => const CadastroPage(),
          '/redefinir': (context) => const RedefinirPage(),
          '/senha': (context) => const SenhaPage(),
          '/itinerario': (context) {
            final userId = FirebaseAuth.instance.currentUser?.uid;
            if (userId == null) {
              return const LoginPage();
            }
            return ItinerariosPage(userId: userId);
          },
          '/favoritos': (context) => const FavoritesPage(),
          '/perfil': (context) => const PerfilPage(),
          '/mapa': (context) => const OpenStreetMapPage(),
        },
      ),
    );
  }
}
