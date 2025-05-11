import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session_model.dart';

class SessionService {
  final String baseUrl = 'http://127.0.0.1:8000';

  Future<List<Session>> getSessionsByFormation(int formationId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/seances/par_formation/?formation_id=$formationId',
      ),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Session.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des séances');
    }
  }

  Future<Session> getSessionById(int sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/seances/$sessionId/'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Session.fromJson(data);
    } else {
      throw Exception('Erreur lors de la récupération de la séance');
    }
  }

  Future<void> addSession({
    required int formationId,
    required String titre,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/seances/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'formation': formationId,
        'titre': titre,
        'date_debut': dateDebut.toIso8601String(),
        'date_fin': dateFin.toIso8601String(),
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la création de la séance');
    }
  }
}
