// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'config.dart';

class StatutInscriptionsPage extends StatefulWidget {
  const StatutInscriptionsPage({super.key});

  @override
  _StatutInscriptionsPageState createState() => _StatutInscriptionsPageState();
}

class _StatutInscriptionsPageState extends State<StatutInscriptionsPage> {
  List<dynamic> _inscriptions = [];
  bool _isLoading = true;
  String? _error;

  // Couleurs du logo AUF
  static const Color aufRed = Color(0xFFAA0036);
  static const Color aufGreen = Color(0xFF91C01E);
  static const Color aufYellow = Color(0xFFFDC300);
  static const Color aufGrey = Color(0xFFBBBCBE);

  @override
  void initState() {
    super.initState();
    _loadInscriptions();
  }

  Future<void> _loadInscriptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? participantId = prefs.getInt('participant_id');
      if (participantId == null) {
        setState(() {
          _error = "Impossible de trouver l'utilisateur connecté";
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          '${AppConfig.apiBaseUrl}/api/inscriptions/?participant_id=$participantId',
        ),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        setState(() {
          _inscriptions = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Erreur lors du chargement des inscriptions";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Erreur de connexion: $e";
        _isLoading = false;
      });
    }
  }

  String _statutLabel(String statut) {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'accepte':
        return 'Accepté';
      case 'refuse':
        return 'Refusé';
      default:
        return statut;
    }
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'en_attente':
        return aufYellow;
      case 'accepte':
        return aufGreen;
      case 'refuse':
        return aufRed;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        title: const Text(
          'Mes Inscriptions',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: aufRed,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInscriptions,
            color: Colors.white,
          ),
        ],
      ), */
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF9F9F9), Colors.white],
          ),
        ),
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(aufRed),
                  ),
                )
                : _error != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: aufRed, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInscriptions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: aufRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
                : _inscriptions.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, color: aufGrey, size: 60),
                      SizedBox(height: 16),
                      Text(
                        'Aucune inscription trouvée',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _inscriptions.length,
                  itemBuilder: (context, index) {
                    final inscription = _inscriptions[index];
                    final formation = inscription['formation'];
                    final qrCode = inscription['qr_code'];
                    final statut = inscription['statut'];

                    // Formatting dates
                    final dateDebut = DateTime.parse(formation['date_debut']);
                    final dateFin = DateTime.parse(formation['date_fin']);
                    final formattedDateDebut =
                        '${dateDebut.day.toString().padLeft(2, '0')}/${dateDebut.month.toString().padLeft(2, '0')}/${dateDebut.year}';
                    final formattedDateFin =
                        '${dateFin.day.toString().padLeft(2, '0')}/${dateFin.month.toString().padLeft(2, '0')}/${dateFin.year}';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: aufRed.withOpacity(0.1),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.school, color: aufRed),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    formation['titre'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      size: 20,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Du $formattedDateDebut au $formattedDateFin",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statutColor(
                                          statut,
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: _statutColor(statut),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            statut == 'accepte'
                                                ? Icons.check_circle
                                                : statut == 'refuse'
                                                ? Icons.cancel
                                                : Icons.access_time,
                                            size: 16,
                                            color: _statutColor(statut),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _statutLabel(statut),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _statutColor(statut),
                                              fontWeight: FontWeight.bold,
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
                          if (statut == 'accepte' && qrCode != null)
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/code_barre',
                                  arguments: {
                                    'name':
                                        '${inscription['participant']['prenom']} ${inscription['participant']['nom']}',
                                    'email':
                                        inscription['participant']['email'],
                                    'phoneNumber':
                                        inscription['participant']['telephone'],
                                    'dateOfBirth':
                                        inscription['participant']['date_naissance'] ??
                                        '',
                                    'lieuNaissance':
                                        inscription['participant']['lieu_naissance'] ??
                                        '',
                                    'formationTitre': formation['titre'],
                                    'formationDate':
                                        '$formattedDateDebut - $formattedDateFin',
                                    'qrCode': qrCode,
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: aufGreen.withOpacity(0.1),
                                  border: Border(
                                    top: BorderSide(
                                      color: aufGrey.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.qr_code_scanner,
                                      color: aufGreen,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Afficher ma carte',
                                      style: TextStyle(
                                        color: aufGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action pour découvrir de nouvelles formations
          // À implémenter selon vos besoins
        },
        backgroundColor: aufBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ), */
    );
  }
}
