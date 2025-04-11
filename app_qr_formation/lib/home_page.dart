import 'package:flutter/material.dart';
import 'Formation.dart'; // Importez votre page Formation
import 'participants_page.dart'; // Importez votre page Participants (si vous en avez une)
//import 'profil_page.dart'; // Importez votre page Profil (si vous en avez une)
import 'ajout_participant.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    _AccueilPageContent(), // Le contenu de votre page d'accueil
    FormationsPage(), // Votre page Formations
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
      body: _children[_currentIndex], // Affiche directement le contenu de la page sélectionnée
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Formations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Participants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        onTap: onTabTapped,
      ),
    );
  }
}

// Extrait le contenu de votre page d'accueil dans un StatelessWidget
class _AccueilPageContent extends StatelessWidget {
  final List<Map<String, String>> formations = [
    {
      'title': 'Formations java',
      'date': '18 mars, 11h:30m',
      'participants': '25 participants',
    },
    {
      'title': 'Formations python',
      'date': '20 mars, 14h:30m',
      'participants': '25 participants',
    },
    {
      'title': 'Formations HTML',
      'date': '28 mars, 16h:30m',
      'participants': '25 participants',
    },
    {
      'title': 'Formations sur Powerpoint',
      'date': '28 mai, 14h:30m',
      'participants': '15 participants',
    },
    {
      'title': 'Formations sur l\'entreprenariat',
      'date': '8 janvier, 10h:30m',
      'participants': '20 participants',
    },
    {
      'title': 'Formations sur E-commence',
      'date': '19 mars, 14h:00m',
      'participants': '35 participants',
    },
    {
      'title': 'Formations IA ',
      'date': '20 mars, 15h:30m',
      'participants': '15 participants',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('QR APP', style: TextStyle(color: Colors.white)), // Titre de la page d'accueil
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Action du menu
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildInfoCard('Nombre total de formations', '12'),
                _buildInfoCard('Nombre de participants actifs', '24'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Formations :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    final homePageState = context.findAncestorStateOfType<_HomePageState>();
                    if (homePageState != null) {
                      homePageState.onTabTapped(1);
                    }
                  },
                  child: Text('voir tout', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: formations.length,
              itemBuilder: (context, index) {
                final formation = formations[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(formation['title']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Text(formation['date']!, style: TextStyle(color: Colors.grey[600])),
                            SizedBox(width: 16),
                            Text(formation['participants']!, style: TextStyle(color: Colors.grey[600])),
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
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
              SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class ParticipantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Participants', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Action du menu
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Recherche un participant....',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // Action pour afficher tous les participants
                  },
                  child: Text('Tous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // Action pour afficher les participants récents
                  },
                  child: Text('Récents'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                _buildParticipantItem(initials: 'AB', name: 'Ali Moussa', email: 'alimoussa.@exemp.com'),
                _buildParticipantItem(initials: 'CE', name: 'Chaibou Elh Issa', email: 'chaibouissa101@gmail.com'),
                _buildParticipantItem(initials: 'KY', name: 'Kabirou Yahaya', email: 'kabirouyahaya190@gmail.com'),
                _buildParticipantItem(initials: 'MI', name: 'Moussa Ismael', email: 'moussaismael121@gmail.com'),
                // Ajoutez d'autres participants ici
              ],
            ),
          ),
        ],
      ),
 floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddParticipantPage()),
    );
  },
  child: Icon(Icons.person_add),
  backgroundColor: Colors.blue,
),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildParticipantItem({required String initials, required String name, required String email}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              radius: 25,
              child: Text(
                initials,
                style: TextStyle(fontSize: 18, color: Colors.blue[800]),
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page de Profil'),
    );
  }
}

class FormationsPage extends StatelessWidget { // Assurez-vous que le nom correspond à l'import dans HomePage
  final List<Map<String, String>> formations = [
    {
      'title': 'Formations java',
      'date': '18 mars, 11h:30m',
      'participants': '25 participants',
    },
    {
      'title': 'Formations python',
      'date': '20 mars, 14h:30m',
      'participants': '25 participants',
    },
    {
      'title': 'Formations HTML',
      'date': '28 mars, 16h:30m',
      'participants': '25 participants',
    },
    {
      'title': 'Formations sur Powerpoint',
      'date': '28 mai, 14h:30m',
      'participants': '15 participants',
    },
    {
      'title': 'Formations sur l\'entreprenariat',
      'date': '8 janvier, 10h:30m',
      'participants': '20 participants',
    },
    {
      'title': 'Formations excel',
      'date': '28 mars, 14h:30m',
      'participants': '32 participants',
    },
    {
      'title': 'Formations BBD',
      'date': '28 mars, 14h:30m',
      'participants': '25 participants',
    },
    {
      'title': 'Formations sur E-commence',
      'date': '19 mars, 14h:00m',
      'participants': '35 participants',
    },
    {
      'title': 'Formations IA ',
      'date': '20 mars, 15h:30m',
      'participants': '15 participants',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Formations', style: TextStyle(color: Colors.white)), // Titre 'Formations' uniquement
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Action du menu
          },
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: formations.length,
        itemBuilder: (context, index) {
          final formation = formations[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(formation['title']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Text(formation['date']!, style: TextStyle(color: Colors.grey[600])),
                      SizedBox(width: 16),
                      Text(formation['participants']!, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action pour ajouter une formation
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}