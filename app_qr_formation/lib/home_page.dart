import 'package:flutter/material.dart';
import 'Formation.dart'; // Importez la page FormationsPage depuis Formation.dart
import 'ajout_participant.dart';
import 'participants_page.dart'; // Importez votre page Participants
import 'services/formation_service.dart'; // Importez le service pour récupérer les formations
import 'models/formation_model.dart'; // Importez le modèle Formation
import 'add_formation_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    _AccueilPageContent(), // Le contenu de votre page d'accueil
    FormationsPage(), // Votre page Formations (importée depuis Formation.dart)
    ParticipantsPage(), // Placeholder pour la page Participants
    ProfilPage(), // Placeholder pour la page Profil
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _children[_currentIndex], // Affiche directement le contenu de la page sélectionnée
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Formations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Participants',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        onTap: onTabTapped,
      ),
    );
  }
}

// Contenu de la page d'accueil
class _AccueilPageContent extends StatefulWidget {
  @override
  __AccueilPageContentState createState() => __AccueilPageContentState();
}

class __AccueilPageContentState extends State<_AccueilPageContent> {
  final FormationService _formationService = FormationService();
  List<Formation> _formations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFormations();
  }

  Future<void> _loadFormations() async {
    try {
      setState(() => _isLoading = true);
      final formations = await _formationService.getFormations();
      setState(() {
        _formations = formations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('QR APP', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Action du menu
          },
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Erreur : $_error'))
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _buildInfoCard(
                          'Nombre total de formations',
                          '${_formations.length}',
                        ),
                        _buildInfoCard(
                          'Nombre de participants actifs',
                          '24',
                        ), // Exemple statique
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Formations :',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final homePageState =
                                context
                                    .findAncestorStateOfType<_HomePageState>();
                            if (homePageState != null) {
                              homePageState.onTabTapped(1);
                            }
                          },
                          child: Text(
                            'voir tout',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _formations.length,
                      itemBuilder: (context, index) {
                        final formation = _formations[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  formation.titre,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      _formatDate(formation.dateDebut),
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      '${formation.placesReservees} participants',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
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

  Widget _buildInfoCard(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
class ProfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Page de Profil'));
  }
}
