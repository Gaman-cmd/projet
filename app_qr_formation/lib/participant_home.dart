// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'config.dart';
import 'formations_a_venir_page.dart';
import 'statut_inscriptions_page.dart';
import 'participant_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Définir les couleurs de l'AUF
class AUFColors {
  static const primary = Color(0xFFB2122B); // Rouge bordeaux AUF
  static const secondary = Color(0xFF333333); // Gris foncé pour le texte
  static const accent1 = Color(0xFF8BC34A); // Vert (cercle du logo)
  static const accent2 = Color(0xFF673AB7); // Violet (cercle du logo)
  static const accent3 = Color(0xFFFFD600); // Jaune (cercle du logo)
  static const accent4 = Color(0xFF03A9F4); // Bleu (cercle du logo)
  static const backgroundLight = Color(0xFFF5F5F5); // Fond clair
  static const cardBackground = Colors.white; // Fond des cartes
}

class ParticipantHomePage extends StatefulWidget {
  const ParticipantHomePage({super.key});

  @override
  State<ParticipantHomePage> createState() => _ParticipantHomePageState();
}

class _ParticipantHomePageState extends State<ParticipantHomePage> {
  int _selectedIndex = 0;

  String prenom = '';
  int nbInscriptions = 0;
  int nbFormationsAVenir = 0;
  int nbFormationsOuvertes = 0;
  List<Map<String, dynamic>> formationsInscrites = [];
  List<Map<String, String>> notifications = [];
  bool isLoading = true;

  final List<String> _appBarTitles = [
    'Accueil',
    'Formations',
    'Mes inscriptions',
    'Profil',
  ];

  @override
  void initState() {
    super.initState();
    _loadAccueilData();
  }

  Future<void> _loadAccueilData() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prenom = prefs.getString('prenom') ?? '';
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final participantId = prefs.getInt('participant_id');

      if (participantId != null) {
        // Charger les formations inscrites
        final response = await http.get(
          Uri.parse(
            '${AppConfig.apiBaseUrl}/api/inscriptions/?participant_id=$participantId',
          ),
        );

        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          setState(() {
            formationsInscrites = List<Map<String, dynamic>>.from(data);
            nbInscriptions = formationsInscrites.length;
          });

          // Mettre à jour les statuts des formations
          formationsInscrites =
              formationsInscrites.map((inscription) {
                final formation = inscription['formation'];
                final DateTime dateDebut = DateTime.parse(
                  formation['date_debut'],
                );
                final DateTime dateFin = DateTime.parse(formation['date_fin']);
                final DateTime now = DateTime.now();

                String statut;
                if (now.isBefore(dateDebut)) {
                  statut = 'a_venir';
                } else if (now.isAfter(dateFin)) {
                  statut = 'terminee';
                } else {
                  statut = 'en_cours';
                }

                formation['statut'] = statut;
                return inscription;
              }).toList();
        }

        // Charger les notifications
        final notifResponse = await http.get(
          Uri.parse(
            '${AppConfig.apiBaseUrl}/api/notifications/$participantId/',
          ),
        );
        if (notifResponse.statusCode == 200) {
          final List notifData = jsonDecode(notifResponse.body);
          setState(() {
            notifications =
                notifData
                    .map<Map<String, String>>(
                      (e) => {
                        'message': (e['message'] ?? '').toString(),
                        'date': (e['date'] ?? '').toString(),
                      },
                    )
                    .toList();
          });
        }
      }

      // Charger les formations à venir
      final responseFormations = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/formations/formations_a_venir/'),
      );
      if (responseFormations.statusCode == 200) {
        final List dataFormations = jsonDecode(responseFormations.body);
        setState(() {
          nbFormationsOuvertes = dataFormations.length;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      // Afficher un message d'erreur à l'utilisateur si nécessaire
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'a_venir':
        return AUFColors.accent3; // Jaune
      case 'en_cours':
        return AUFColors.accent1; // Vert
      case 'terminee':
        return AUFColors.accent4; // Bleu
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'a_venir':
        return 'À venir';
      case 'en_cours':
        return 'En cours';
      case 'terminee':
        return 'Terminée';
      default:
        return status.isEmpty ? 'Inconnu' : status;
    }
  }

  Widget _accueilWidget() {
    return RefreshIndicator(
      color: AUFColors.primary,
      onRefresh: _loadAccueilData,
      child:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: AUFColors.primary),
              )
              : Container(
                color: AUFColors.backgroundLight,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // En-tête avec salutation
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AUFColors.primary,
                            AUFColors.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 24,
                                child: Text(
                                  prenom.isNotEmpty
                                      ? prenom[0].toUpperCase()
                                      : "?",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AUFColors.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bonjour,',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    prenom,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Statistiques
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Formations inscrites',
                            nbInscriptions,
                            AUFColors.accent2,
                            Icons.school,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _statCard(
                            'Formations à venir',
                            nbFormationsOuvertes,
                            AUFColors.accent1,
                            Icons.event_available,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Titre de section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AUFColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Mes formations inscrites',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AUFColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Liste des formations
                    formationsInscrites.isEmpty
                        ? Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AUFColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune formation inscrite',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextButton(
                                onPressed:
                                    () => _onItemTapped(
                                      1,
                                    ), // Aller à l'onglet Formations
                                child: Text(
                                  'Découvrir les formations',
                                  style: TextStyle(color: AUFColors.primary),
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: formationsInscrites.length,
                          itemBuilder: (context, index) {
                            final f = formationsInscrites[index]['formation'];
                            String statut = '';
                            final rawStatut =
                                (f['statut'] ?? '').toString().toLowerCase();
                            statut = _getStatusText(rawStatut);

                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AUFColors.cardBackground,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AUFColors.primary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.school,
                                            color: AUFColors.primary,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                f['titre'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Du ${f['date_debut']?.substring(0, 10) ?? ''} au ${f['date_fin']?.substring(0, 10) ?? ''}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.grey.shade100,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        rawStatut,
                                      ).withOpacity(0.05),
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                  rawStatut,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Statut: $statut',
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                  rawStatut,
                                                ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
    );
  }

  Widget _statCard(String label, int value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AUFColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 16),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AUFColors.secondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  static final List<Widget> _staticPages = <Widget>[
    // Placeholder, remplacé dynamiquement dans build()
    SizedBox.shrink(),
    FormationsAVenirPage(),
    StatutInscriptionsPage(),
    ParticipantProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = List<Widget>.from(_staticPages);
    pages[0] = _accueilWidget();

    return Scaffold(
      backgroundColor: AUFColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/AUF-Nouveau-Logo.png', // Assurez-vous d'avoir ce logo dans vos assets
              height: 32,
            ),
            SizedBox(width: 8),
            Text(_appBarTitles[_selectedIndex]),
          ],
        ),
        backgroundColor: AUFColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions:
            _selectedIndex == 0
                ? [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_outlined),
                        tooltip: 'Notifications',
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder:
                                (context) => Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AUFColors.primary,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Notifications',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                              onPressed:
                                                  () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child:
                                            notifications.isEmpty
                                                ? Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .notifications_off_outlined,
                                                        size: 64,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade400,
                                                      ),
                                                      SizedBox(height: 16),
                                                      Text(
                                                        'Aucune notification',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                : ListView.separated(
                                                  padding: EdgeInsets.all(16),
                                                  itemCount:
                                                      notifications.length,
                                                  separatorBuilder:
                                                      (_, __) => Divider(),
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    final notif =
                                                        notifications[index];
                                                    return ListTile(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 16,
                                                          ),
                                                      leading: Container(
                                                        padding: EdgeInsets.all(
                                                          10,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                              color: AUFColors
                                                                  .accent2
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                        child: Icon(
                                                          Icons.notifications,
                                                          color:
                                                              AUFColors.accent2,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        notif['message'] ?? '',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      subtitle: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              top: 4,
                                                            ),
                                                        child: Text(
                                                          notif['date'] ?? '',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade600,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                      ),
                                    ],
                                  ),
                                ),
                          );
                        },
                      ),
                      if (notifications.isNotEmpty)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AUFColors.accent3,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 8,
                              minHeight: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ]
                : null,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: AUFColors.primary,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Formations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Inscriptions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
