import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/formation_model.dart';
import '../models/user_model.dart';

class FormationService {
  final String baseUrl = AppConfig.apiBaseUrl;

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

  Future<String> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/api/upload-image/');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        // Supposons que le serveur renvoie l'URL de l'image dans la réponse
        return responseData;
      } else {
        throw Exception('Échec du téléchargement de l\'image');
      }
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de l\'image: $e');
    }
  }

  Future<Formation> getFormationDetails(int formationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/formations/$formationId/'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Le backend doit inclure les infos du formateur dans la réponse
        return Formation.fromJson(jsonData);
      } else {
        throw Exception(
          'Erreur lors du chargement des détails de la formation',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  Future<List> getFormationsByParticipant(int participantId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/formations/par_participant/?participant_id=$participantId',
      ),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des formations');
    }
  }

  Future<List<Formation>> getFormationsByFormateur(int formateurId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/formations/par_formateur/?formateur_id=$formateurId',
      ),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => Formation.fromJson(data)).toList();
    } else {
      throw Exception(
        'Erreur lors de la récupération des formations du formateur',
      );
    }
  }

  Future<List<User>> getFormateurs() async {
    final response = await http.get(Uri.parse('$baseUrl/api/formateurs/'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des formateurs');
    }
  }

  Future<void> updateFormation(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/formations/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la modification : ${response.body}');
    }
  }
}
