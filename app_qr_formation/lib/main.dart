import 'package:flutter/material.dart';
import 'formateur_home_page.dart';
import 'login_screen.dart';
import 'home_page.dart'; // La page principale de ton app
import 'register_screen.dart'; // Importer l'écran d'enregistrement
import 'formations_a_venir_page.dart';
import 'statut_inscriptions_page.dart'; // à créer
import 'code_barre.dart';
import 'participant_home.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  Intl.defaultLocale = 'fr_FR';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth Demo',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomePage(),
        '/register': (context) => RegisterScreen(),
        '/formations_a_venir': (context) => FormationsAVenirPage(),
        '/formateur_home': (context) => FormateurHomePage(),
        '/statut_inscriptions':
            (context) => StatutInscriptionsPage(), // <--- AJOUTE ICI
        '/code_barre': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return CodeBarrePage(
            name: args['name'],
            email: args['email'],
            phoneNumber: args['phoneNumber'],
            dateOfBirth: args['dateOfBirth'],
            lieuNaissance: args['lieuNaissance'],
            formationTitre: args['formationTitre'], // <-- Ajouté
            formationDate: args['formationDate'], // <-- Ajouté
            qrCode: args['qrCode'], // <-- Ajouté
          );
        },
        '/participant_home': (context) => ParticipantHomePage(),
      },
    );
  }
}

/*class AuthChecker extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}   */
