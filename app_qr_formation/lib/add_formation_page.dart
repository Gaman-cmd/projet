import 'package:flutter/material.dart';
import 'services/formation_service.dart';

class AddFormationPage extends StatefulWidget {
  @override
  _AddFormationPageState createState() => _AddFormationPageState();
}

class _AddFormationPageState extends State<AddFormationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lieuController = TextEditingController();
  final _placesTotalController = TextEditingController();
  final _contactEmailController = TextEditingController();
  DateTime? _dateDebut;
  DateTime? _dateFin;

  final FormationService _formationService = FormationService();

  Future<void> _submitFormation() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _formationService.addFormation({
          'titre': _titreController.text,
          'description': _descriptionController.text,
          'date_debut': _dateDebut?.toIso8601String(),
          'date_fin': _dateFin?.toIso8601String(),
          'lieu': _lieuController.text,
          'places_total': int.parse(_placesTotalController.text),
          'contact_email': _contactEmailController.text,
          'statut': 'a_venir',
        });
        Navigator.pop(context); // Retour à la page précédente après ajout
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout de la formation : $e'),
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _dateDebut = picked;
        } else {
          _dateFin = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nouvelle Formation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade50],
            stops: [0.0, 0.2],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Détails de la formation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _titreController,
                        label: 'Titre',
                        icon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un titre';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        icon: Icons.description,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _lieuController,
                        label: 'Lieu',
                        icon: Icons.location_on,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un lieu';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _placesTotalController,
                        label: 'Nombre de places',
                        icon: Icons.people,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nombre de places';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _contactEmailController,
                        label: 'Email de contact',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un email de contact';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      _buildDateSelector(context),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submitFormation,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Ajouter la Formation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue.shade700),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _dateDebut == null
                            ? 'Date de début : Non sélectionnée'
                            : 'Date de début : ${_dateDebut!.toLocal()}'.split(
                              ' ',
                            )[0],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text('Sélectionner'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue.shade700),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _dateFin == null
                            ? 'Date de fin : Non sélectionnée'
                            : 'Date de fin : ${_dateFin!.toLocal()}'.split(
                              ' ',
                            )[0],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text('Sélectionner'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
