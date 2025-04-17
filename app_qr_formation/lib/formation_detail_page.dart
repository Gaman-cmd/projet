import 'package:flutter/material.dart';
import 'models/formation_model.dart';

class FormationDetailPage extends StatefulWidget {
  final Formation formation;

  const FormationDetailPage({Key? key, required this.formation})
    : super(key: key);

  @override
  _FormationDetailPageState createState() => _FormationDetailPageState();
}

class _FormationDetailPageState extends State<FormationDetailPage> {
  // Index de l'onglet sélectionné (0: Information, 1: Participants, 2: Présences)
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Détails de la formation',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête image avec les informations de formation
            Stack(
              children: [
                // Image d'arrière-plan
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/formation.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Superposition semi-transparente pour améliorer la lisibilité du texte
                Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.black.withOpacity(0.4),
                ),
                // Contenu textuel sur l'image
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Formation java',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '18 mars 2025',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(width: 20),
                          Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '14:30 - 18:30',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'À venir',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Section des onglets d'information interactifs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildTabButton(0, 'Information'),
                  _buildTabButton(1, 'Participants(25)'),
                  _buildTabButton(2, 'Présences'),
                ],
              ),
            ),

            // Contenu qui change en fonction de l'onglet sélectionné
            _buildSelectedTabContent(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: Icon(Icons.camera_alt),
        tooltip: 'Scanner',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Construction de chaque bouton d'onglet
  Widget _buildTabButton(int index, String title) {
    bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Construction du contenu en fonction de l'onglet sélectionné
  Widget _buildSelectedTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildInformationContent();
      case 1:
        return _buildParticipantsContent();
      case 2:
        return _buildPresencesContent();
      default:
        return _buildInformationContent();
    }
  }

  // Contenu de l'onglet Information
  Widget _buildInformationContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Cette formation avancée en Java s\'adresse aux développeurs qui souhaitent approfondir leurs connaissances et maîtriser les concepts avancés du langage',
              style: TextStyle(fontSize: 15),
            ),
          ),
          SizedBox(height: 24),

          // Section Détails
          Text(
            'Détails',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Table des détails
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonne gauche
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('14 mars 2025'),
                    SizedBox(height: 20),
                    Text('Lieu', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Salle de conférence A'),
                    SizedBox(height: 20),
                    Text(
                      'Formateur',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Thomas Dubois'),
                  ],
                ),
              ),
              // Colonne droite
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horaires',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('14:30 - 18:30'),
                    SizedBox(height: 20),
                    Text(
                      'Places',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('25 / 30'),
                    SizedBox(height: 20),
                    Text(
                      'Contact',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('formation@example.com'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Contenu de l'onglet Participants
  Widget _buildParticipantsContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Liste des participants',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Liste des participants
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 5, // Exemple avec 5 participants
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              // Exemple de participants
              return _buildParticipantCard(
                'Participant ${index + 1}',
                'participant${index + 1}@example.com',
              );
            },
          ),

          SizedBox(height: 20),
          // Bouton pour ajouter un participant
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add),
            label: Text('Ajouter un participant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: Size(double.infinity, 45),
            ),
          ),
        ],
      ),
    );
  }

  // Contenu de l'onglet Présences
  Widget _buildPresencesContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion des présences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'La formation n\'a pas encore eu lieu. Les présences pourront être enregistrées le jour de la formation.',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Statistiques de présence
          Text(
            'Statistiques',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Cartes de statistiques
          Row(
            children: [
              Expanded(child: _buildStatCard('Inscrits', '25', Colors.blue)),
              SizedBox(width: 10),
              Expanded(child: _buildStatCard('Présents', '0', Colors.green)),
              SizedBox(width: 10),
              Expanded(child: _buildStatCard('Absents', '0', Colors.red)),
            ],
          ),

          SizedBox(height: 24),
          // Bouton pour scanner les présences
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.qr_code_scanner),
            label: Text('Scanner les présences'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: Size(double.infinity, 45),
            ),
          ),
        ],
      ),
    );
  }

  // Card pour afficher les statistiques
  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 5),
          Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(String name, String email) {
    // Obtenir les initiales à partir du nom
    String initials =
        name.isNotEmpty
            ? name
                .split(' ')
                .map((word) => word.isNotEmpty ? word[0] : '')
                .join('')
            : '??';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue[100],
            child: Text(
              initials,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(email, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          // Options pour chaque participant
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
  }
}
