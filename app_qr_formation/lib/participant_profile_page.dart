import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_participant_profile_page.dart';

class ParticipantProfilePage extends StatefulWidget {
  const ParticipantProfilePage({super.key});

  @override
  State<ParticipantProfilePage> createState() => _ParticipantProfilePageState();
}

class _ParticipantProfilePageState extends State<ParticipantProfilePage> {
  Map<String, String> participant = {};
  bool isLoading = true;

  // Couleurs du logo AUF
  static const Color aufRed = Color(0xFFAA0036);
  static const Color aufGreen = Color(0xFF91C01E);
  static const Color aufPurple = Color(0xFF7F3F98);
  static const Color aufYellow = Color(0xFFFDC300);
  static const Color aufBlue = Color(0xFF0093D0);
  static const Color aufGrey = Color(0xFFBBBCBE);

  @override
  void initState() {
    super.initState();
    _loadParticipant();
  }

  Future<void> _loadParticipant() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      participant = {
        'nom': prefs.getString('nom') ?? '',
        'prenom': prefs.getString('prenom') ?? '',
        'email': prefs.getString('email') ?? '',
        'telephone': prefs.getString('telephone') ?? '',
        'dateNaissance': prefs.getString('dateNaissance') ?? '',
        'lieuNaissance': prefs.getString('lieuNaissance') ?? '',
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: aufRed,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadParticipant,
            color: Colors.white,
          ),
        ],
      ), */
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(aufRed),
                ),
              )
              : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF9F9F9), Colors.white],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      _buildInformationCard(),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileHeader() {
    // Obtenir les initiales pour l'avatar
    String initials =
        (participant['prenom']!.isNotEmpty
            ? participant['prenom']![0].toUpperCase()
            : '') +
        (participant['nom']!.isNotEmpty
            ? participant['nom']![0].toUpperCase()
            : '');

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [aufRed.withOpacity(0.8), aufRed.withOpacity(0.6)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 36,
                  color: aufRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '${participant['prenom']} ${participant['nom']}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                participant['email']!,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: aufPurple.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: aufPurple),
                  const SizedBox(width: 10),
                  const Text(
                    'Informations personnelles',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _infoRow(
                    Icons.phone_outlined,
                    'Téléphone',
                    participant['telephone']!,
                    aufBlue,
                  ),
                  _divider(),
                  _infoRow(
                    Icons.cake_outlined,
                    'Date de naissance',
                    participant['dateNaissance']!,
                    aufGreen,
                  ),
                  _divider(),
                  _infoRow(
                    Icons.location_on_outlined,
                    'Lieu de naissance',
                    participant['lieuNaissance']!,
                    aufYellow,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      child: Column(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Modifier mon profil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: aufBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              minimumSize: const Size(double.infinity, 54),
              elevation: 2,
            ),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              int participantId = prefs.getInt('participant_id') ?? 0;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditParticipantProfilePage(
                        participant: participant,
                        participantId: participantId,
                      ),
                ),
              );
              if (result == true) {
                _loadParticipant(); // Recharge le profil après modification
              }
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Déconnexion'),
            style: OutlinedButton.styleFrom(
              foregroundColor: aufRed,
              side: BorderSide(color: aufRed),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              minimumSize: const Size(double.infinity, 54),
            ),
            onPressed: () {
              // Implémentez la déconnexion ici
              // Par exemple :
              // SharedPreferences prefs = await SharedPreferences.getInstance();
              // prefs.clear();
              // Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'Non renseigné' : value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: value.isEmpty ? Colors.grey : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => Divider(height: 24, color: Colors.grey[200]);
}
