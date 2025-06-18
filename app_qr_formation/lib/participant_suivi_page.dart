import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'models/participant_model.dart';
import 'services/attendance_service.dart';
import 'theme.dart';

class ParticipantSuiviPage extends StatefulWidget {
  final Participant participant;
  final int formationId;
  final String formationTitre;

  const ParticipantSuiviPage({
    Key? key,
    required this.participant,
    required this.formationId,
    required this.formationTitre,
  }) : super(key: key);

  @override
  State<ParticipantSuiviPage> createState() => _ParticipantSuiviPageState();
}

class _ParticipantSuiviPageState extends State<ParticipantSuiviPage> {
  late Future<Map<String, dynamic>> _suiviDataFuture;

  @override
  void initState() {
    super.initState();
    _suiviDataFuture = _loadSuiviData();
  }

  Future<Map<String, dynamic>> _loadSuiviData() async {
    final presences = await AttendanceService().getParticipantPresences(
      widget.formationId,
      widget.participant.id,
    );

    int totalSeances = presences.length;
    int seancesPresent =
        presences.where((p) => p['statut'] == 'present').length;
    double pourcentagePresence =
        totalSeances > 0 ? (seancesPresent / totalSeances) * 100 : 0.0;

    return {
      'presences': presences,
      'totalSeances': totalSeances,
      'seancesPresent': seancesPresent,
      'pourcentagePresence': pourcentagePresence,
    };
  }

  Color _getProgressColor(double pourcentage) {
    if (pourcentage >= 80) return Colors.green;
    if (pourcentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getParticipantInitials() {
    return '${widget.participant.prenom[0]}${widget.participant.nom[0]}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AUFTheme.background,
      appBar: AppBar(
        title: Text('Suivi du participant'),
        backgroundColor: AUFTheme.primary,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _suiviDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final pourcentage = data['pourcentagePresence'] as double;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildStatisticsCard(data),
                _buildPresencesList(data['presences']),
                _buildContactInfo(),
                _buildSuggestions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AUFTheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              _getParticipantInitials(),
              style: TextStyle(
                fontSize: 30,
                color: AUFTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '${widget.participant.prenom} ${widget.participant.nom}',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.formationTitre,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          if (widget.participant.dateGenerationQr != null)
            Text(
              'QR Code généré le: ${widget.participant.dateGenerationQr!.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(Map<String, dynamic> data) {
    final pourcentage = data['pourcentagePresence'] as double;
    return Padding(
      padding: EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Taux de présence',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 13.0,
                animation: true,
                percent: pourcentage / 100,
                center: Text(
                  "${pourcentage.toStringAsFixed(1)}%",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: _getProgressColor(pourcentage),
              ),
              SizedBox(height: 20),
              Text(
                '${data['seancesPresent']}/${data['totalSeances']} séances',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresencesList(List presences) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Détail des séances',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (presences.isEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Aucune séance trouvée pour ce participant.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: presences.length,
                itemBuilder: (context, index) {
                  final presence = presences[index];
                  final seance = presence['seance'];
                  return ListTile(
                    leading: Icon(
                      presence['statut'] == 'present'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color:
                          presence['statut'] == 'present'
                              ? Colors.green
                              : Colors.red,
                    ),
                    title: Text(
                      seance != null && seance['titre'] != null
                          ? seance['titre']
                          : 'Séance ${index + 1}',
                    ),
                    subtitle: Text(
                      seance != null && seance['date_debut'] != null
                          ? 'Date : ${seance['date_debut'].toString().split("T")[0]}'
                          : '',
                    ),
                    trailing: Text(
                      presence['statut'] == 'present' ? 'Présent' : 'Absent',
                      style: TextStyle(
                        color:
                            presence['statut'] == 'present'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations de contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: Icon(Icons.email, color: AUFTheme.primary),
                title: Text(widget.participant.email),
              ),
              ListTile(
                leading: Icon(Icons.phone, color: AUFTheme.primary),
                title: Text(widget.participant.telephone),
              ),
              if (widget.participant.dateNaissance != null)
                ListTile(
                  leading: Icon(Icons.cake, color: AUFTheme.primary),
                  title: Text(widget.participant.dateNaissance!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suggestions de suivi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AUFTheme.primary,
                ),
              ),
              SizedBox(height: 8),
              Text('• Ajouter un graphique d’évolution de la présence.'),
              Text(
                '• Permettre au formateur d’ajouter un commentaire sur le suivi.',
              ),
              Text('• Générer un rapport PDF du suivi.'),
              Text(
                '• Envoyer une notification si le taux de présence est faible.',
              ),
              Text(
                '• Ajouter des badges de réussite pour les participants assidus.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
