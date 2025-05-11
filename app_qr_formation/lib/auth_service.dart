import 'dart:convert';
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
      final data = jsonDecode(response.body);
      return {'status': true, 'user': data['user']};
    } else {
      final data = jsonDecode(response.body);
      return {'status': false, 'message': data['error'] ?? 'Erreur'};
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

  // Fonction d'inscription pour créer un nouvel utilisateur
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String nom,
    String prenom,
    String telephone,
    String dateNaissance,
    String lieuNaissance,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'date_naissance': dateNaissance,
        'lieu_naissance': lieuNaissance,
      }),
    );
    if (response.statusCode == 201) {
      return {'status': true};
    } else {
      return {'status': false, 'message': 'Erreur lors de l\'inscription'};
    }
  }
}
