import 'package:flutter/material.dart';
import 'services/participant_service.dart';
import 'models/participant_model.dart';
import 'models/formation_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectParticipantsPage extends StatefulWidget {
  final int formationId;
  final Formation formation;

  const SelectParticipantsPage({
    super.key,
    required this.formationId,
    required this.formation,
  });

  @override
  _SelectParticipantsPageState createState() => _SelectParticipantsPageState();
}

class _SelectParticipantsPageState extends State<SelectParticipantsPage> {
  // Ajoute les couleurs du logo AUF
  final Color primaryColor = const Color(0xFFA6092B); // Rouge AUF
  final Color accentColor = const Color(0xFF2196F3); // Bleu
  final Color greenColor = const Color(0xFF8BC34A); // Vert
  final Color purpleColor = const Color(0xFF9C27B0); // Violet
  final Color yellowColor = const Color(0xFFFFC107); // Jaune

  List<Map<String, dynamic>> _inscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInscriptions();
  }

  Future<void> _loadInscriptions() async {
    setState(() => _isLoading = true);
    try {
      final service = ParticipantService();
      final inscriptions = await service.getInscriptionsByFormation(
        widget.formationId,
      );
      setState(() {
        // On ne garde que les inscriptions en attente
        _inscriptions =
            inscriptions.where((i) => i['statut'] == 'en_attente').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  Future<void> _validerInscription(
    int inscriptionId,
    String statut,
    Map participant,
  ) async {
    final response = await http.post(
      Uri.parse(
        'http://127.0.0.1:8000/api/inscriptions/$inscriptionId/valider/',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'statut': statut}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'])));
      if (statut == 'accepte') {
        // Affiche la carte QR
        Navigator.pushNamed(
          context,
          '/code_barre',
          arguments: {
            'name': '${participant['nom']} ${participant['prenom']}',
            'email': participant['email'],
            'phoneNumber': participant['telephone'],
            'dateOfBirth': participant['date_naissance'] ?? '',
            'lieuNaissance': participant['lieu_naissance'] ?? '',
            'formationTitre': widget.formation.titre,
            'formationDate':
                '${widget.formation.dateDebut.day}/${widget.formation.dateDebut.month}/${widget.formation.dateDebut.year} - ${widget.formation.dateFin.day}/${widget.formation.dateFin.month}/${widget.formation.dateFin.year}',
            'qrCode': data['qr_code'],
          },
        );
      }
      _loadInscriptions();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur lors de la validation")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Valider les inscriptions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
              : Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    color: primaryColor.withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: primaryColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Validez ou refusez les demandes d\'inscription',
                            style: TextStyle(fontSize: 16, color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _inscriptions.length,
                      itemBuilder: (context, index) {
                        final insc = _inscriptions[index];
                        final participant = insc['participant'];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: primaryColor,
                              child: Text(
                                participant['nom'][0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              '${participant['nom']} ${participant['prenom']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4),
                                    Text(participant['email']),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(Icons.check),
                                  label: Text('Accepter'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: greenColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed:
                                      () => _validerInscription(
                                        insc['id'],
                                        'accepte',
                                        participant,
                                      ),
                                ),
                                SizedBox(width: 8),
                                OutlinedButton.icon(
                                  icon: Icon(Icons.close),
                                  label: Text('Refuser'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed:
                                      () => _validerInscription(
                                        insc['id'],
                                        'refuse',
                                        participant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
