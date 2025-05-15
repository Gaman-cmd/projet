// ignore_for_file: unnecessary_null_comparison, use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'services/participant_service.dart';
import 'services/attendance_service.dart';
import 'models/participant_model.dart';

class PresenceManagementPage extends StatefulWidget {
  final String seanceTitle;
  final String seanceDetails;
  final int seanceId; // Ajoute l'id de la séance

  const PresenceManagementPage({
    Key? key,
    required this.seanceTitle,
    required this.seanceDetails,
    required this.seanceId,
  }) : super(key: key);

  @override
  _PresenceManagementPageState createState() => _PresenceManagementPageState();
}

class _PresenceManagementPageState extends State<PresenceManagementPage> {
  // Couleurs du logo AUF
  final Color primaryColor = const Color(0xFFA6092B); // Rouge AUF
  final Color accentColor = const Color(0xFF2196F3); // Bleu
  final Color greenColor = const Color(0xFF8BC34A); // Vert
  final Color purpleColor = const Color(0xFF9C27B0); // Violet
  final Color yellowColor = const Color(0xFFFFC107); // Jaune

  List<Participant> participants = [];
  Set<int> presents = {};

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    try {
      // Récupère les inscriptions de la formation
      final inscriptions = await ParticipantService()
          .getInscriptionsByFormation(widget.seanceId);

      // Filtre pour ne garder que les participants acceptés
      final participantsAcceptes =
          inscriptions
              .where((i) => i['statut'] == 'accepte')
              .map((i) => Participant.fromJson(i['participant']))
              .toList();

      setState(() {
        participants = participantsAcceptes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des participants: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _scanCode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        // Trouver le participant par QR code
        final participant = participants.firstWhere(
          (p) => p.qrCode == result.rawContent,
          orElse: () => throw Exception('Participant not found'),
        );
        if (participant != null) {
          // Marquer la présence via l'API
          await AttendanceService().markAttendance(
            widget.seanceId,
            participant.id,
            "present",
          );
          setState(() {
            presents.add(participant.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Présence marquée pour ${participant.prenom} ${participant.nom}',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Participant non trouvé')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors du scan : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion des présences',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.1), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.seanceTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: accentColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            widget.seanceDetails,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Liste des participants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final p = participants[index];
                      final isPresent = presents.contains(p.id);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isPresent ? greenColor : Colors.grey[300],
                          child: Icon(
                            isPresent ? Icons.check : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          '${p.prenom} ${p.nom}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        subtitle: Text(
                          p.email,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isPresent
                                    ? greenColor.withOpacity(0.1)
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPresent ? greenColor : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            isPresent ? 'Présent' : 'Absent',
                            style: TextStyle(
                              color: isPresent ? greenColor : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanCode,
        backgroundColor: primaryColor,
        icon: Icon(Icons.qr_code_scanner),
        label: Text('Scanner'),
        elevation: 4,
      ),
    );
  }
}
