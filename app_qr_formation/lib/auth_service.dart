/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      "http://127.0.0.1:8000"; // Remplace par l'URL de ton API

  // Fonction de connexion pour récupérer le token
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Si la requête est un succès, on récupère le token
      final Map<String, dynamic> data = jsonDecode(response.body);
      final token = data['access'];

      // Sauvegarder le token localement
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);

      return {'status': true, 'token': token};
    } else {
      // Si l'authentification échoue, retourner une erreur
      return {'status': false, 'message': 'Identifiants invalides'};
    }
  }

  // Fonction pour récupérer le token depuis les SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fonction pour vérifier si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Fonction pour déconnecter l'utilisateur
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }
}
 */
