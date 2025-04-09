import 'package:flutter/material.dart';
import 'home_page.dart'; // Importez le fichier home_page.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // Définissez LoginPage comme écran de démarrage
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[800],
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.add, size: 20, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email ou nom d\'utilisateur',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Ajoutez ici la logique pour "Mot de passe oublié ?"
                },
                child: Text('Mot de passe oublié ?'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // **NAVIGATION VERS LA PAGE D'ACCUEIL**
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('Se connecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 2, 112, 238),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 50),
            TextButton(
              onPressed: () {
                // Ajoutez ici la logique d'inscription
              },
              child: Text('Inscription'),
            ),
          ],
        ),
      ),
    );
  }
}