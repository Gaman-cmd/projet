import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_page.dart'; // La page principale de ton app
//import 'auth_service.dart'; // Importer ton service AuthService

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      initialRoute: '/login',
      routes: {
        //'/':
        //    (context) =>
        //        AuthChecker(), // Vérifier si l'utilisateur est authentifié
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomePage(),
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
