/*import 'package:flutter/material.dart';
import 'services/participant_service.dart';
import 'services/formation_service.dart';
import 'models/formation_model.dart';
import 'code_barre.dart';

class AddParticipantPage extends StatefulWidget {
  @override
  _AddParticipantPageState createState() => _AddParticipantPageState();
}

class _AddParticipantPageState extends State<AddParticipantPage> {
  final _formKey = GlobalKey<FormState>();
  final _participantService = ParticipantService();
  final _formationService = FormationService();
  bool _isLoading = false;

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _birthDate = '';
  String _Lieufrom = '';
  Formation? _selectedFormation;
  List<Formation> _formations = [];
  bool _isLoadingFormations = true;

  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFormations();
  }

  Future<void> _loadFormations() async {
    try {
      final formations = await _formationService.getFormations();
      setState(() {
        _formations = formations;
        _isLoadingFormations = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement des formations: ${e.toString()}'),
        ),
      );
      setState(() => _isLoadingFormations = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'), // Pour avoir le calendrier en français
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
        _birthDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildFormationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Formation *',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<Formation>(
          value: _selectedFormation,
          decoration: InputDecoration(
            hintText: 'Sélectionner une formation',
            border: OutlineInputBorder(),
          ),
          items:
              _formations.map((Formation formation) {
                return DropdownMenuItem<Formation>(
                  value: formation,
                  child: Text(formation.titre),
                );
              }).toList(),
          validator: (value) {
            if (value == null) {
              return 'Veuillez sélectionner une formation';
            }
            return null;
          },
          onChanged: (Formation? newValue) {
            setState(() {
              _selectedFormation = newValue;
            });
          },
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        await _participantService.createParticipant(
          nom: _lastName,
          prenom: _firstName,
          email: _email,
          telephone: _phone,
          dateNaissance: _birthDate,
          lieuNaissance: _Lieufrom,
          formationId: _selectedFormation!.id,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant ajouté avec succès')),
        );

        // Navigue vers la page carte/QR code
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => CodeBarrePage(
                  name: '$_firstName $_lastName',
                  email: _email,
                  phoneNumber: _phone,
                  dateOfBirth: _birthDate,
                  lieuNaissance: _Lieufrom,
                ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Date de naissance *',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une date de naissance';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un participant'),
        backgroundColor: Colors.blue,
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
              _buildDateField(),
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
              _isLoadingFormations
                  ? Center(child: CircularProgressIndicator())
                  : _buildFormationDropdown(),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
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
} */
