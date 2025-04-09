import 'package:flutter/material.dart';

class FormationsPage extends StatelessWidget {
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
        backgroundColor: const Color.fromARGB(255, 231, 3, 3),
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

class ParticipantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page des Participants'),
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