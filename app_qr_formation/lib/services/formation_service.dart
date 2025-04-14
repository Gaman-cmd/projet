import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/formation_model.dart';

class FormationService {
  final String baseUrl = 'http://127.0.0.1:8000';

  Future<List<Formation>> getFormations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/formations/'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => Formation.fromJson(data)).toList();
      } else {
        throw Exception(
          'Échec du chargement des formations: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<void> addFormation(Map<String, dynamic> formationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/formations/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(formationData),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Erreur lors de l\'ajout de la formation : ${response.body}',
      );
    }
  }
}
