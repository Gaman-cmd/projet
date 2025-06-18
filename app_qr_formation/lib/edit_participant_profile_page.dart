// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'config.dart';

class AUFColors {
  static const Color primary = Color(0xFFB2122B); // Rouge AUF
  static const Color secondary = Color(0xFF333333);
  static const Color accent1 = Color(0xFF8BC34A);
  static const Color accent2 = Color(0xFF673AB7);
  static const Color accent3 = Color(0xFFFFD600);
  static const Color accent4 = Color(0xFF03A9F4);
  static const Color background = Color(0xFFF5F5F5);
}

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
        '${AppConfig.apiBaseUrl}/api/modifier_profil/${widget.participantId}/',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nomController.text,
        'prenom': prenomController.text,
        'telephone': telephoneController.text,
        'dateNaissance': dateNaissanceController.text,
        'lieuNaissance': lieuNaissanceController.text,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('nom', nomController.text);
      prefs.setString('prenom', prenomController.text);
      prefs.setString('telephone', telephoneController.text);
      prefs.setString('dateNaissance', dateNaissanceController.text);
      prefs.setString('lieuNaissance', lieuNaissanceController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: AUFColors.primary,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AUFColors.background,
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        backgroundColor: AUFColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        elevation: 1,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AUFColors.primary),
              )
              : Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        const SizedBox(height: 12),
                        Center(
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: AUFColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              color: AUFColors.primary,
                              size: 44,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          controller: nomController,
                          label: 'Nom',
                          icon: Icons.badge,
                          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                        ),
                        _buildTextField(
                          controller: prenomController,
                          label: 'Prénom',
                          icon: Icons.person_outline,
                          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                        ),
                        _buildTextField(
                          controller: telephoneController,
                          label: 'Téléphone',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          controller: dateNaissanceController,
                          label: 'Date de naissance (YYYY-MM-DD)',
                          icon: Icons.cake,
                          keyboardType: TextInputType.datetime,
                        ),
                        _buildTextField(
                          controller: lieuNaissanceController,
                          label: 'Lieu de naissance',
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Enregistrer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AUFColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 2,
                          ),
                          onPressed: _saveProfile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AUFColors.primary),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AUFColors.primary.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AUFColors.primary.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AUFColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
