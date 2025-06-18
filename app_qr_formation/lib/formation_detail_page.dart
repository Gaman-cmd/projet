// ignore_for_file: use_super_parameters, library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously, sort_child_properties_last, sized_box_for_whitespace, prefer_interpolation_to_compose_strings, unused_local_variable

import 'package:flutter/material.dart';
//import 'ajout_participant.dart';
import 'config.dart';
import 'edit_formation_page.dart';
import 'models/participant_model.dart';
import 'models/session_model.dart';
import 'participant_suivi_page.dart';
import 'services/formation_service.dart';
import 'models/formation_model.dart';
import 'presence_management_page.dart';
import 'services/participant_service.dart';
import 'select_participants_page.dart';
import 'services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Pour le formatage des dates

class FormationDetailPage extends StatefulWidget {
  final int formationId;

  const FormationDetailPage({Key? key, required this.formationId})
    : super(key: key);

  @override
  _FormationDetailPageState createState() => _FormationDetailPageState();
}

class _FormationDetailPageState extends State<FormationDetailPage>
    with TickerProviderStateMixin {
  late Future<Formation> _formationFuture;
  final FormationService _formationService = FormationService();
  final ParticipantService _participantService = ParticipantService();
  late Future<List<Session>> _sessionsFuture;
  late TabController _tabController;

  List<Participant> _selectedParticipants = [];
  String? _role;

  // Couleurs basées sur le logo AUF
  final Color primaryColor = const Color(0xFFA6092B); // Rouge AUF
  final Color accentColor = const Color(0xFF2196F3); // Bleu du logo
  final Color greenColor = const Color(0xFF8BC34A); // Vert du logo
  final Color purpleColor = const Color(0xFF9C27B0); // Violet du logo
  final Color yellowColor = const Color(0xFFFFC107); // Jaune du logo

  @override
  void initState() {
    super.initState();
    _formationFuture = _formationService.getFormationDetails(
      widget.formationId,
    );
    _loadParticipants();
    _sessionsFuture = SessionService().getSessionsByFormation(
      widget.formationId,
    );
    _loadRole();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role');
    });
  }

  void _loadParticipants() async {
    final inscriptions = await _participantService.getInscriptionsByFormation(
      widget.formationId,
    );
    final participantsAcceptes =
        inscriptions
            .where((i) => i['statut'] == 'accepte')
            .map((i) => Participant.fromJson(i['participant']))
            .toList();
    setState(() {
      _selectedParticipants = participantsAcceptes;
    });
  }

  Future<void> _inscrireAFormation(int formationId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? participantId = prefs.getInt('participant_id');
      if (participantId == null) {
        _showSnackBar("Impossible de trouver l'utilisateur connecté");
        return;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/inscription/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "participant_id": participantId,
          "formation_id": formationId,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar(
          "Demande d'inscription envoyée. Attendez la validation de l'admin.",
        );
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(data['error'] ?? "Erreur lors de l'inscription");
      }
    } catch (e) {
      _showSnackBar("Erreur lors de l'inscription: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Détails de la formation'),
          backgroundColor: primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }

    final isParticipant = _role == 'participant';
    final isAdmin = _role == 'admin';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Détails de la formation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        /* actions: [
          if (isAdmin)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditFormationPage(formation: formation),
                  ),
                );
                if (result == true) {
                  setState(() {
                    _formationFuture = _formationService.getFormationDetails(
                      widget.formationId,
                    );
                  });
                }
              },
            ),
        ], */
      ),
      body: FutureBuilder<Formation>(
        future: _formationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: primaryColor, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _formationFuture = _formationService
                            .getFormationDetails(widget.formationId);
                      });
                    },
                    child: Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final formation = snapshot.data!;
            if (isParticipant) {
              return _buildParticipantView(formation);
            } else {
              return _buildAdminView(formation);
            }
          } else {
            return Center(child: Text('Aucune donnée disponible'));
          }
        },
      ),
    );
  }

  Widget _buildParticipantView(Formation formation) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormationHeader(formation),
          _buildInformationContent(formation),
        ],
      ),
    );
  }

  Widget _buildAdminView(Formation formation) {
    return Column(
      children: [
        _buildFormationHeader(formation),
        if (_role == 'admin')
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 16.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: ElevatedButton.icon(
                icon: Icon(Icons.edit),
                label: Text('Modifier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditFormationPage(formation: formation),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _formationFuture = _formationService.getFormationDetails(
                        widget.formationId,
                      );
                    });
                  }
                },
              ),
            ),
          ),
        TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          tabs: [
            Tab(icon: Icon(Icons.info_outline), text: 'Information'),
            Tab(
              icon: Icon(Icons.people),
              text: 'Participants (${_selectedParticipants.length})',
            ),
            Tab(icon: Icon(Icons.calendar_today), text: 'Séances'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(child: _buildInformationContent(formation)),
              SingleChildScrollView(
                child: _buildParticipantsContent(formation),
              ),
              SingleChildScrollView(child: _buildPresencesContent(formation)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInformationContent(Formation formation) {
    String formatDate(DateTime date) {
      return DateFormat('dd/MM/yyyy').format(date);
    }

    String getFormateurName() {
      if (formation.formateur != null) {
        return "${formation.formateur!['prenom']} ${formation.formateur!['nom']}";
      }
      return 'Non assigné';
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Description', Icons.description),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(formation.description, style: TextStyle(height: 1.5)),
          ),
          SizedBox(height: 24),
          _buildSectionTitle('Détails', Icons.details),
          SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem(
                          Icons.calendar_today,
                          'Date début',
                          formatDate(formation.dateDebut),
                          accentColor,
                        ),
                        SizedBox(height: 20),
                        _buildDetailItem(
                          Icons.location_on,
                          'Lieu',
                          formation.lieu,
                          greenColor,
                        ),
                        SizedBox(height: 20),
                        _buildDetailItem(
                          Icons.person,
                          'Formateur',
                          getFormateurName(),
                          purpleColor,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem(
                          Icons.event_available,
                          'Date fin',
                          formatDate(formation.dateFin),
                          accentColor,
                        ),
                        SizedBox(height: 20),
                        _buildDetailItem(
                          Icons.people,
                          'Places',
                          '${_selectedParticipants.length}/${formation.placesTotal}',
                          yellowColor,
                        ),
                        SizedBox(height: 20),
                        _buildDetailItem(
                          Icons.email,
                          'Contact',
                          formation.contactEmail,
                          purpleColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
          if (_role == 'participant')
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.how_to_reg),
                label: Text("S'inscrire à cette formation"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => _inscrireAFormation(formation.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsContent(Formation formation) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Liste des participants', Icons.people),
          SizedBox(height: 16),
          if (_selectedParticipants.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun participant inscrit',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _selectedParticipants.length,
              itemBuilder: (context, index) {
                final participant = _selectedParticipants[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Text(
                        participant.nom[0].toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      '${participant.prenom} ${participant.nom}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(participant.email),
                    trailing:
                        _role == 'admin'
                            ? IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                // Logique pour supprimer un participant
                              },
                            )
                            : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ParticipantSuiviPage(
                                participant: participant,
                                formationId: widget.formationId,
                                formationTitre: formation.titre,
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          SizedBox(height: 20),
          if (_role != 'formateur')
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => SelectParticipantsPage(
                          formationId: formation.id,
                          formation: formation,
                        ),
                  ),
                );
                if (result != null && result is List<Participant>) {
                  for (final participant in result) {
                    await _participantService.addParticipantToFormation(
                      participantId: participant.id,
                      formationId: widget.formationId,
                    );
                  }
                  _loadParticipants();
                }
              },
              icon: Icon(Icons.person_add),
              label: Text('Ajouter des participants'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPresencesContent(Formation formation) {
    // Vérifie si la formation est terminée
    bool isFormationTerminee = formation.statutAuto == 'terminee';

    return FutureBuilder<List<Session>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: primaryColor, size: 60),
                SizedBox(height: 16),
                Text('Erreur lors du chargement des séances'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _sessionsFuture = SessionService().getSessionsByFormation(
                        widget.formationId,
                      );
                    });
                  },
                  child: Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        final seances = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Liste des séances', Icons.event_note),
              SizedBox(height: 16),
              if (seances.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune séance planifiée',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: seances.length,
                  itemBuilder: (context, index) {
                    final seance = seances[index];
                    final seanceTitle =
                        seance.titre.isNotEmpty
                            ? seance.titre
                            : 'Séance ${index + 1}';

                    // Format pour les dates et heures
                    final dateDebut = DateFormat(
                      'dd/MM/yyyy',
                    ).format(seance.dateDebut);
                    final heureDebut = DateFormat(
                      'HH:mm',
                    ).format(seance.dateDebut);
                    final heureFin = DateFormat('HH:mm').format(seance.dateFin);

                    // Détermine la couleur selon le statut (passé/futur/aujourd'hui)
                    Color statusColor;
                    if (seance.dateDebut.isBefore(
                      DateTime.now().subtract(Duration(days: 1)),
                    )) {
                      statusColor = Colors.grey; // Passé
                    } else if (seance.dateDebut.day == DateTime.now().day) {
                      statusColor = greenColor; // Aujourd'hui
                    } else {
                      statusColor = accentColor; // Futur
                    }

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PresenceManagementPage(
                                    seanceId: seance.id,
                                    seanceTitle: seanceTitle,
                                    seanceDetails:
                                        '$dateDebut • $heureDebut - $heureFin',
                                    formationId:
                                        formation
                                            .id, // <-- Passe l'ID de la formation ici
                                  ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.event_note,
                                  color: statusColor,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      seanceTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          dateDebut,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '$heureDebut - $heureFin',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: statusColor),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              SizedBox(height: 24),
              // Ajoute la condition pour n'afficher le bouton que pour les formateurs
              if (_role == 'formateur')
                if (isFormationTerminee)
                  // Message d'erreur si la formation est terminée
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'La formation est terminée. Vous ne pouvez plus créer de séances pour cette formation. Veuillez contacter votre administrateur.',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Bouton d'ajout de séance si la formation n'est pas terminée
                  ElevatedButton.icon(
                    onPressed:
                        () => _showAddSessionDialog(
                          formation,
                        ), // Passe la formation ici
                    icon: Icon(Icons.add),
                    label: Text('Ajouter une séance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddSessionDialog(Formation formation) async {
    final DateTime formationDateDebut = formation.dateDebut;
    final DateTime formationDateFin = formation.dateFin;

    final titreController = TextEditingController();
    DateTime? dateDebut;
    TimeOfDay? heureDebut;
    TimeOfDay? heureFin;

    final result = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.add_circle, color: primaryColor),
                  SizedBox(width: 8),
                  Text('Ajouter une séance'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titreController,
                      decoration: InputDecoration(
                        labelText: 'Titre de la séance',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Date de la séance:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: primaryColor,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            dateDebut = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 10),
                            Text(
                              dateDebut != null
                                  ? DateFormat('dd/MM/yyyy').format(dateDebut!)
                                  : 'Sélectionner une date',
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Heure de début:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: primaryColor,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      heureDebut = picked;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time),
                                      SizedBox(width: 10),
                                      Text(
                                        heureDebut != null
                                            ? '${heureDebut!.hour.toString().padLeft(2, '0')}:${heureDebut!.minute.toString().padLeft(2, '0')}'
                                            : 'Début',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Heure de fin:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: primaryColor,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      heureFin = picked;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time),
                                      SizedBox(width: 10),
                                      Text(
                                        heureFin != null
                                            ? '${heureFin!.hour.toString().padLeft(2, '0')}:${heureFin!.minute.toString().padLeft(2, '0')}'
                                            : 'Fin',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Annuler',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titreController.text.isEmpty ||
                        dateDebut == null ||
                        heureDebut == null ||
                        heureFin == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Veuillez remplir tous les champs'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Vérification de l'intervalle de dates
                    if (dateDebut!.isBefore(formationDateDebut) ||
                        dateDebut!.isAfter(formationDateFin)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "La date de la séance doit être comprise entre le ${DateFormat('dd/MM/yyyy').format(formationDateDebut)} et le ${DateFormat('dd/MM/yyyy').format(formationDateFin)}.",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Combine date et heure
                    final dateTimeDebut = DateTime(
                      dateDebut!.year,
                      dateDebut!.month,
                      dateDebut!.day,
                      heureDebut!.hour,
                      heureDebut!.minute,
                    );

                    final dateTimeFin = DateTime(
                      dateDebut!.year,
                      dateDebut!.month,
                      dateDebut!.day,
                      heureFin!.hour,
                      heureFin!.minute,
                    );

                    Navigator.pop(context, {
                      'titre': titreController.text,
                      'dateDebut': dateTimeDebut,
                      'dateFin': dateTimeFin,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      try {
        await SessionService().addSession(
          formationId: widget.formationId,
          titre: result['titre'],
          dateDebut: result['dateDebut'],
          dateFin: result['dateFin'],
        );

        setState(() {
          _sessionsFuture = SessionService().getSessionsByFormation(
            widget.formationId,
          );
        });

        _showSnackBar('Séance ajoutée avec succès');
      } catch (e) {
        _showSnackBar('Erreur lors de l\'ajout de la séance');
      }
    }
  }

  Widget _buildFormationHeader(Formation formation) {
    return Container(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          // Affiche l'image de la formation si elle existe, sinon une image par défaut
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    (formation.imageUrl.isNotEmpty &&
                            formation.imageUrl.startsWith('http'))
                        ? NetworkImage(formation.imageUrl)
                        : AssetImage('assets/images/formation.jpg')
                            as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formation.titre,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(formation.dateDebut) +
                          ' - ' +
                          DateFormat('dd/MM/yyyy').format(formation.dateFin),
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(formation.statutAuto),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(formation.statutAuto),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'a_venir':
        return yellowColor;
      case 'en_cours':
        return greenColor;
      case 'terminee':
        return Colors.grey;
      default:
        return accentColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'a_venir':
        return 'À venir';
      case 'en_cours':
        return 'En cours';
      case 'terminee':
        return 'Terminée';
      default:
        return status;
    }
  }
}
