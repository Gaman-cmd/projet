import 'package:flutter/material.dart';
import 'ajout_participant.dart'; // Assurez-vous que le chemin est correct
import 'code_barre.dart'; // Importer la page code_barre

class ParticipantsPage extends StatelessWidget {
  const ParticipantsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Participants', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
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
                prefixIcon: const Icon(Icons.search),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Tous'),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // Action pour afficher les participants récents
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Récents'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                _buildParticipantItem(
                  context,
                  initials: 'AB',
                  name: 'Ali Moussa',
                  email: 'alimoussa.@exemp.com',
                  phoneNumber: '+22798765432',
                  dateOfBirth: '15/03/1990',
                  lieuNaissance: 'A Tahoua',
                ),
                _buildParticipantItem(
                  context,
                  initials: 'CE',
                  name: 'Chaibou Elh Issa',
                  email: 'chaibouissa101@gmail.com',
                  phoneNumber: '+22788576328',
                  dateOfBirth: '20/02/2000',
                  lieuNaissance:'A Niamey'
                ),
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
        backgroundColor: Colors.blue,
        child: const Icon(Icons.person_add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildParticipantItem(
    BuildContext context, {
    required String initials,
    required String name,
    required String email,
    required String phoneNumber,
    required String dateOfBirth,
    required String lieuNaissance,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CodeBarrePage(
              name: name,
              email: email,
              phoneNumber: phoneNumber,
              dateOfBirth: dateOfBirth,
              lieuNaissance: lieuNaissance,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
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
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(email, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}