import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/participant_model.dart';

class ParticipantService {
  final String baseUrl = 'http://127.0.0.1:8000'; // Pour l'émulateur Android
  // Utilisez 'localhost' pour iOS

  Future<Participant> createParticipant({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String dateNaissance,
    required String lieuNaissance,
    required int formationId, // Ajout du paramètre formationId
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/participants/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'date_naissance': dateNaissance,
        'lieu_naissance': lieuNaissance,
        'formation_id': formationId, // Inclusion dans la requête
      }),
    );

    if (response.statusCode == 201) {
      return Participant.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Erreur lors de la création du participant: ${response.body}',
      );
    }
  }

  Future<List<Participant>> getAllParticipants() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/participants/'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Participant.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Service non disponible');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } on TimeoutException {
      throw Exception('Délai d\'attente dépassé');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  Future<List<Participant>> getParticipantsByFormation(int formationId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/participants/par_formation/?formation_id=$formationId',
      ),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Participant.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des participants');
    }
  }

  Future<void> addParticipantToFormation({
    required int participantId,
    required int formationId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/inscriptions/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'participant': participantId,
        'formation': formationId,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Erreur lors de l\'ajout du participant à la formation');
    }
  }

  Future<List<Map<String, dynamic>>> getInscriptionsByFormation(
    int formationId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/inscriptions/?formation_id=$formationId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération des inscriptions');
    }
  }
}
