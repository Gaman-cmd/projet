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
  List<Participant> participants = [];
  Set<int> presents = {};

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    // Récupère les participants inscrits à la formation liée à la séance
    // Il te faut l'id de la formation, à passer à cette page ou à récupérer via l'API si besoin
    // Supposons que tu passes formationId à cette page
    final participantsList = await ParticipantService()
        .getParticipantsByFormation(widget.seanceId);
    setState(() {
      participants = participantsList;
    });
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
        title: Text('Gestion des présences'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.seanceTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.seanceDetails,
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final p = participants[index];
                  return ListTile(
                    leading: Icon(
                      presents.contains(p.id)
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          presents.contains(p.id) ? Colors.green : Colors.grey,
                    ),
                    title: Text('${p.prenom} ${p.nom}'),
                    subtitle: Text(p.email),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanCode,
        backgroundColor: Colors.blue,
        child: Icon(Icons.qr_code_scanner),
        tooltip: 'Scanner un code',
      ),
    );
  }
}
