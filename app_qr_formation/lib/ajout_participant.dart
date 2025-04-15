import 'package:flutter/material.dart';

class AddParticipantPage extends StatefulWidget {
  @override
  _AddParticipantPageState createState() => _AddParticipantPageState();
}

class _AddParticipantPageState extends State<AddParticipantPage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _birthDate = '';
  String _Lieufrom = '';
  String? _selectedFormation; // Pour gérer la sélection unique

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un participant'),
        backgroundColor: Colors.blue, // Couleur de la barre d'appli
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Informations personnelles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Prénom *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prénom';
                  }
                  return null;
                },
                onSaved: (value) => _firstName = value!,
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom';
                  }
                  return null;
                },
                onSaved: (value) => _lastName = value!,
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Téléphone *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro de téléphone';
                  }
                  return null;
                },
                onSaved: (value) => _phone = value!,
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date de naissance *',
                  border: OutlineInputBorder(),
                ),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrez la date de naissance';
                  }
                  return null;
                },
                onSaved: (value) => _birthDate = value!,
              ),
              SizedBox(height: 14),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Lieu de naissance *',
                  border: OutlineInputBorder(),
                ),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrez le lieu de naissance';
                  }
                  return null;
                },
                onSaved: (value) => _birthDate = value!,
              ),
              SizedBox(height: 14),
              Text(
                'Formations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              RadioListTile<String>(
                title: Text('Formation en Java'),
                value: 'java',
                groupValue: _selectedFormation,
                onChanged: (String? value) {
                  setState(() {
                    _selectedFormation = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Formation en Python'),
                value: 'python',
                groupValue: _selectedFormation,
                onChanged: (String? value) {
                  setState(() {
                    _selectedFormation = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Formation en HTML'),
                value: 'HTML',
                groupValue: _selectedFormation,
                onChanged: (String? value) {
                  setState(() {
                    _selectedFormation = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Formation en Excel'),
                value: 'Excel',
                groupValue: _selectedFormation,
                onChanged: (String? value) {
                  setState(() {
                    _selectedFormation = value;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Ici, vous pouvez traiter les données du formulaire
                    print('Prénom: $_firstName');
                    print('Nom: $_lastName');
                    print('Email: $_email');
                    print('Téléphone: $_phone');
                    print('Date de naissance: $_birthDate');
                     print('Lieu de naissance: $_Lieufrom');
                    print('Formation sélectionnée: $_selectedFormation');
                    // Vous pouvez également ajouter ici la logique pour ajouter le participant
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Couleur du bouton
                  foregroundColor: Colors.white, // Couleur du texte du bouton
                ),
                child: Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}