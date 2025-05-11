// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'models/participant_model.dart';
import 'models/session_model.dart';
import 'services/participant_service.dart';

class SessionDetailPage extends StatefulWidget {
  final Session session;

  SessionDetailPage({required this.session});

  @override
  _SessionDetailPageState createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  List<Participant> participants = [];
  Map<int, bool> presenceStatus = {};

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    // Charger les participants depuis le service
    final loadedParticipants = await ParticipantService().getAllParticipants();
    setState(() {
      participants = loadedParticipants;
      presenceStatus = {for (var p in participants) p.id: false};
    });
  }

  void _togglePresence(int participantId) {
    setState(() {
      presenceStatus[participantId] = !(presenceStatus[participantId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.session.titre)),
      body: ListView.builder(
        itemCount: participants.length,
        itemBuilder: (context, index) {
          final participant = participants[index];
          return ListTile(
            title: Text('${participant.prenom} ${participant.nom}'),
            subtitle: Text(participant.email),
            trailing: Checkbox(
              value: presenceStatus[participant.id],
              onChanged: (value) {
                _togglePresence(participant.id);
              },
            ),
          );
        },
      ),
    );
  }
}
