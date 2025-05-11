import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditParticipantProfilePage extends StatefulWidget {
  final Map<String, String> participant;
  final int participantId;
  const EditParticipantProfilePage({
    super.key,
    required this.participant,
    required this.participantId,
  });

  @override
  State<EditParticipantProfilePage> createState() =>
      _EditParticipantProfilePageState();
}

class _EditParticipantProfilePageState
    extends State<EditParticipantProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController telephoneController;
  late TextEditingController dateNaissanceController;
  late TextEditingController lieuNaissanceController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nomController = TextEditingController(text: widget.participant['nom']);
    prenomController = TextEditingController(
      text: widget.participant['prenom'],
    );
    telephoneController = TextEditingController(
      text: widget.participant['telephone'],
    );
    dateNaissanceController = TextEditingController(
      text: widget.participant['dateNaissance'],
    );
    lieuNaissanceController = TextEditingController(
      text: widget.participant['lieuNaissance'],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final response = await http.put(
      Uri.parse(
        'http://127.0.0.1:8000/api/modifier_profil/${widget.participantId}/',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nomController.text,
        'prenom': prenomController.text,
        'telephone': telephoneController.text,
        'date_naissance': dateNaissanceController.text,
        'lieu_naissance': lieuNaissanceController.text,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      // Mets à jour SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('nom', nomController.text);
      prefs.setString('prenom', prenomController.text);
      prefs.setString('telephone', telephoneController.text);
      prefs.setString('dateNaissance', dateNaissanceController.text);
      prefs.setString('lieuNaissance', lieuNaissanceController.text);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profil mis à jour avec succès')));
      Navigator.pop(context, true); // Retour à la page profil
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de la mise à jour')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier mon profil'),
        backgroundColor: Colors.indigo,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: nomController,
                        decoration: InputDecoration(labelText: 'Nom'),
                        validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                      ),
                      TextFormField(
                        controller: prenomController,
                        decoration: InputDecoration(labelText: 'Prénom'),
                        validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                      ),
                      TextFormField(
                        controller: telephoneController,
                        decoration: InputDecoration(labelText: 'Téléphone'),
                      ),
                      TextFormField(
                        controller: dateNaissanceController,
                        decoration: InputDecoration(
                          labelText: 'Date de naissance (YYYY-MM-DD)',
                        ),
                      ),
                      TextFormField(
                        controller: lieuNaissanceController,
                        decoration: InputDecoration(
                          labelText: 'Lieu de naissance',
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        label: Text('Enregistrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: _saveProfile,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
