// ignore_for_file: unnecessary_null_comparison, use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously, sort_child_properties_last, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/participant_service.dart';
import 'services/attendance_service.dart';
import 'models/participant_model.dart';
import 'models/attendance_model.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class PresenceManagementPage extends StatefulWidget {
  final String seanceTitle;
  final String seanceDetails;
  final int seanceId;
  final int formationId; // <-- Ajoute ce champ

  const PresenceManagementPage({
    Key? key,
    required this.seanceTitle,
    required this.seanceDetails,
    required this.seanceId,
    required this.formationId, // <-- Ajoute ce champ
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
  String _role = '';

  List<Map<String, dynamic>> inscriptions = [];
  List<Attendance> attendances = [];

  String _statutFiltre = 'tous'; // 'tous', 'present', 'absent'

  late DateTime seanceDateTimeDebut;
  late DateTime seanceDateTimeFin;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _loadParticipantsAndAttendances();
    try {
      final parts = widget.seanceDetails.split('•');
      final datePart = parts[0].trim();
      final timeParts = parts[1].trim().split('-');
      final heureDebut = timeParts[0].trim();
      final heureFin = timeParts.length > 1 ? timeParts[1].trim() : heureDebut;

      final dateComponents = datePart.split('/');
      final debutComponents = heureDebut.split(':');
      final finComponents = heureFin.split(':');

      seanceDateTimeDebut = DateTime(
        int.parse(dateComponents[2]),
        int.parse(dateComponents[1]),
        int.parse(dateComponents[0]),
        int.parse(debutComponents[0]),
        int.parse(debutComponents[1]),
      );
      seanceDateTimeFin = DateTime(
        int.parse(dateComponents[2]),
        int.parse(dateComponents[1]),
        int.parse(dateComponents[0]),
        int.parse(finComponents[0]),
        int.parse(finComponents[1]),
      );
    } catch (e) {
      final now = DateTime.now();
      seanceDateTimeDebut = now;
      seanceDateTimeFin = now.add(Duration(hours: 1)); // valeur par défaut
    }
  }

  bool _isSeanceTerminee() {
    return DateTime.now().isAfter(seanceDateTimeFin);
  }

  Future<void> _loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role') ?? '';
    });
  }

  Future<void> _loadParticipants() async {
    try {
      // Récupère les inscriptions acceptées de la formation
      final fetchedInscriptions = await ParticipantService()
          .getInscriptionsByFormation(widget.formationId);

      final inscriptionsAcceptees =
          fetchedInscriptions.where((i) => i['statut'] == 'accepte').toList();

      setState(() {
        inscriptions = inscriptionsAcceptees;
        participants =
            inscriptionsAcceptees.map((i) {
              final p = Participant.fromJson(i['participant']);
              return Participant(
                id: p.id,
                nom: p.nom,
                prenom: p.prenom,
                email: p.email,
                telephone: p.telephone,
                dateNaissance: p.dateNaissance,
                lieuNaissance: p.lieuNaissance,
                qrCode: i['qr_code'],
                actif: p.actif, // Ajoute ceci
                dateCreation:
                    p.dateCreation, // Ajoute aussi les autres requis si besoin
              );
            }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des participants'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadAttendances() async {
    try {
      final fetchedAttendances = await AttendanceService()
          .getAttendancesBySession(widget.seanceId);
      setState(() {
        attendances = fetchedAttendances;
        presents =
            fetchedAttendances
                .where((a) => a.statut == 'present')
                .map((a) => a.participant['id'] as int)
                .toSet();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des présences'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadParticipantsAndAttendances() async {
    await _loadParticipants();
    await _loadAttendances();
  }

  void _showScannerDialog() {
    // Vérifie si la séance est terminée
    if (_isSeanceTerminee()) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Séance terminée'),
                ],
              ),
              content: Text(
                'Cette séance est terminée ${_getTempsEcoule()}. Vous ne pouvez plus scanner les présences.',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
      );
      return;
    }

    // Le reste du code existant pour le scanner...
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: 400,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Scanner le QR Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: MobileScanner(
                        controller: MobileScannerController(),
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            _handleScannedCode(barcode.rawValue ?? '');
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Fermer le scanner',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _handleScannedCode(String scannedCode) async {
    try {
      print('Scanned: $scannedCode');
      for (final insc in inscriptions) {
        print(
          'Inscription: ${insc['participant']['nom']} ${insc['participant']['prenom']} - QR: ${insc['qr_code']}',
        );
      }

      String? scannedQr;
      try {
        final decoded = jsonDecode(scannedCode);
        scannedQr = decoded['qr_code'];
      } catch (_) {
        scannedQr = scannedCode;
      }

      final inscription = inscriptions.firstWhere(
        (i) => (i['qr_code'] ?? '').trim() == (scannedQr ?? '').trim(),
        orElse: () => throw Exception('Inscription non trouvée'),
      );

      final participant = Participant.fromJson(inscription['participant']);

      // Vérifie si le participant est déjà marqué présent
      if (presents.contains(participant.id)) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${participant.prenom} ${participant.nom} est déjà présent pour cette séance.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(10),
          ),
        );
        return;
      }

      await AttendanceService().markAttendance(
        widget.seanceId,
        participant.id,
        "present",
      );

      await _loadAttendances(); // Recharge la liste des présences

      setState(() {
        presents.add(participant.id);
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Présence marquée pour ${participant.prenom} ${participant.nom}',
          ),
          backgroundColor: greenColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
    }
  }

  Future<void> _exportParticipantsCSV() async {
    List<List<String>> rows = [
      ['Nom', 'Prénom', 'Email', 'Statut'],
    ];
    for (final p in participants) {
      final isPresent = presents.contains(p.id);
      rows.add([p.nom, p.prenom, p.email, isPresent ? 'Présent' : 'Absent']);
    }
    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/participants_${widget.seanceId}.csv';
    final file = File(path);
    await file.writeAsString(csvData);

    await Share.shareXFiles([XFile(path)], text: 'Liste des participants');
  }

  // Modifie aussi _getTempsEcoule() pour utiliser seanceDateTimeFin
  String _getTempsEcoule() {
    final difference = DateTime.now().difference(seanceDateTimeFin);
    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredParticipants =
        _statutFiltre == 'tous'
            ? participants
            : participants.where((p) {
              final isPresent = presents.contains(p.id);
              if (_statutFiltre == 'present') return isPresent;
              if (_statutFiltre == 'absent') return !isPresent;
              return true;
            }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion des présences',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadParticipantsAndAttendances,
          ),
          IconButton(
            icon: Icon(Icons.download),
            tooltip: 'Exporter la liste',
            onPressed: _exportParticipantsCSV,
          ),
        ],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilterChip(
                    label: Text('Tous'),
                    selected: _statutFiltre == 'tous',
                    onSelected: (_) => setState(() => _statutFiltre = 'tous'),
                    selectedColor: greenColor.withOpacity(0.2),
                  ),
                  SizedBox(width: 8),
                  FilterChip(
                    label: Text('Présents'),
                    selected: _statutFiltre == 'present',
                    onSelected:
                        (_) => setState(() => _statutFiltre = 'present'),
                    selectedColor: greenColor.withOpacity(0.2),
                  ),
                  SizedBox(width: 8),
                  FilterChip(
                    label: Text('Absents'),
                    selected: _statutFiltre == 'absent',
                    onSelected: (_) => setState(() => _statutFiltre = 'absent'),
                    selectedColor: Colors.orange.withOpacity(0.2),
                  ),
                ],
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
                    itemCount: filteredParticipants.length,
                    itemBuilder: (context, index) {
                      final p = filteredParticipants[index];
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
      floatingActionButton:
          _role != 'admin'
              ? FloatingActionButton.extended(
                onPressed: _showScannerDialog,
                backgroundColor:
                    _isSeanceTerminee()
                        ? Colors
                            .grey // Grise le bouton si la séance est terminée
                        : primaryColor,
                icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                label: Text('Scanner', style: TextStyle(color: Colors.white)),
                elevation: 4,
              )
              : null,
    );
  }
}
