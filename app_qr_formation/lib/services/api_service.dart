import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';

class ApiService {
  final String baseUrl =
      AppConfig.apiBaseUrl; // Remplacez par l'URL de votre backend

  Future<Map<String, dynamic>> login(String email, String motDePasse) async {
    final url = Uri.parse('$baseUrl/api/login/');
    final response = await http.post(
      url,
      body: {'email': email, 'mot_de_passe': motDePasse},
    );

    if (response.statusCode == 200) {
      return json.decode(
        response.body,
      ); // Retourne le token et d'autres données
    } else {
      throw Exception('Erreur de connexion : ${response.body}');
    }
  }
}
