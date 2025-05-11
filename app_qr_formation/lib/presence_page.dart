/*import 'package:flutter/material.dart';
import 'models/session_model.dart';
import 'services/attendance_service.dart';
import 'models/attendance_model.dart';

class PresencePage extends StatefulWidget {
  final Session seance;
  PresencePage({required this.seance});

  @override
  State<PresencePage> createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  List<Attendance> presences = [];

  @override
  void initState() {
    super.initState();
    _loadPresences();
  }

  Future<void> _loadPresences() async {
    presences = await AttendanceService().getAttendancesBySession(
      widget.seance.id,
    );
    setState(() {});
  }

  void _togglePresence(int attendanceId, String statut) async {
    await AttendanceService().updateAttendance(attendanceId, statut);
    _loadPresences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Présence')),
      body:
          presences.isEmpty
              ? Center(child: Text('Aucun participant'))
              : ListView.builder(
                itemCount: presences.length,
                itemBuilder: (context, index) {
                  final p = presences[index];
                  return ListTile(
                    title: Text('${p.participantNom} ${p.participantPrenom}'),
                    subtitle: Text('Statut : ${p.statut}'),
                    trailing: DropdownButton<String>(
                      value: p.statut,
                      items: [
                        DropdownMenuItem(
                          value: 'present',
                          child: Text('Présent'),
                        ),
                        DropdownMenuItem(
                          value: 'absent',
                          child: Text('Absent'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          _togglePresence(p.id, val);
                        }
                      },
                    ),
                  );
                },
              ),
    );
  }
}
*/
