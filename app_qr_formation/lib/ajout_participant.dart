import 'package:flutter/material.dart';
import 'services/participant_service.dart';

class AddParticipantPage extends StatefulWidget {
  @override
  _AddParticipantPageState createState() => _AddParticipantPageState();
}

class _AddParticipantPageState extends State<AddParticipantPage> {
  final _formKey = GlobalKey<FormState>();
  final _participantService = ParticipantService();
  bool _isLoading = false;

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _birthDate = '';
  String _Lieufrom = '';
  String? _selectedFormation; // Pour gérer la sélection unique

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final participant = await _participantService.createParticipant(
          nom: _lastName,
          prenom: _firstName,
          email: _email,
          telephone: _phone,
          dateNaissance: _birthDate,
          lieuNaissance: _Lieufrom,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Participant ajouté avec succès')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

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
                onSaved: (value) => _Lieufrom = value!,
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
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Couleur du bouton
                  foregroundColor: Colors.white, // Couleur du texte du bouton
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
