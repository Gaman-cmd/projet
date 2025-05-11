import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attendance_model.dart';

class AttendanceService {
  final String baseUrl = 'http://127.0.0.1:8000';

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

  Future<void> markAttendance(
    int seanceId,
    int participantId,
    String statut,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/presences/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'seance': seanceId,
        'participant': participantId,
        'statut': statut,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la création de la présence');
    }
  }

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
}
