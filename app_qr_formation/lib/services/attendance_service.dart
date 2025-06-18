// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final String baseUrl = AppConfig.apiBaseUrl;

  /// Récupérer les présences par séance
  Future<List<Attendance>> getAttendancesBySession(int seanceId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/presences/par_seance/?seance_id=$seanceId'),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Attendance.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des présences');
    }
  }

  /// Marquer la présence d’un participant
  Future<void> markAttendance(
    int seanceId,
    int participantId,
    String statut,
  ) async {
    // On récupère l'ID de l'utilisateur connecté (scanneur)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? scanneParId = prefs.getInt('user_id');

    final response = await http.post(
      Uri.parse('$baseUrl/api/presences/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'seance_id': seanceId,
        'participant_id': participantId,
        'statut': statut,
        'scanne_par': scanneParId, // facultatif mais recommandé
      }),
    );

    if (response.statusCode != 201) {
      print(response.body); // pour debug
      throw Exception('Erreur lors de la création de la présence');
    }
    print(
      jsonEncode({
        'seance_id': seanceId,
        'participant_id': participantId,
        'statut': statut,
        'scanne_par': scanneParId,
      }),
    );
  }

  /// Modifier le statut de présence existant
  Future<void> updateAttendance(int attendanceId, String statut) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/presences/$attendanceId/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'statut': statut}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la modification de la présence');
    }
  }

  /// Récupérer les présences d'un participant pour une formation
  Future<List<dynamic>> getParticipantPresences(
    int formationId,
    int participantId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/presences/participant/?formation_id=$formationId&participant_id=$participantId',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Erreur backend: ${response.statusCode} - ${response.body}');
      throw Exception(
        'Erreur lors de la récupération des présences du participant',
      );
    }
  }
}
