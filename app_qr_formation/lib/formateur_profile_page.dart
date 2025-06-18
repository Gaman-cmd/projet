// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AUFColors {
  static const Color primary = Color(0xFFB2122B);
  static const Color secondary = Color(0xFF333333);
  static const Color accent1 = Color(0xFF8BC34A);
  static const Color accent2 = Color(0xFF673AB7);
  static const Color accent3 = Color(0xFFFFD600);
  static const Color accent4 = Color(0xFF03A9F4);
  static const Color background = Color(0xFFF5F5F5);
}

class FormateurProfilePage extends StatefulWidget {
  const FormateurProfilePage({super.key});

  @override
  State<FormateurProfilePage> createState() => _FormateurProfilePageState();
}

class _FormateurProfilePageState extends State<FormateurProfilePage> {
  String nom = '';
  String prenom = '';
  String email = '';
  String telephone = '';
  String dateNaissance = '';
  String lieuNaissance = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nom = prefs.getString('nom') ?? '';
      prenom = prefs.getString('prenom') ?? '';
      email = prefs.getString('email') ?? '';
      telephone = prefs.getString('telephone') ?? '';
      dateNaissance = prefs.getString('dateNaissance') ?? '';
      lieuNaissance = prefs.getString('lieuNaissance') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AUFColors.background,
      /*appBar: AppBar(
        backgroundColor: AUFColors.primary,
        elevation: 0,
        title: const Text(
          "Profil Formateur",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ), */
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AUFColors.primary.withOpacity(0.1),
              child: Icon(Icons.person, color: AUFColors.primary, size: 56),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              "$prenom $nom",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AUFColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              email,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  _profileRow(Icons.phone, "Téléphone", telephone),
                  const Divider(),
                  _profileRow(Icons.cake, "Date de naissance", dateNaissance),
                  const Divider(),
                  _profileRow(
                    Icons.location_on,
                    "Lieu de naissance",
                    lieuNaissance,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              // Efface les données de session
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              // Redirige vers la page de login
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text("Déconnexion"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AUFColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AUFColors.primary, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AUFColors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
