// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'models/formation_model.dart';
import 'services/formation_service.dart';
import 'theme.dart'; // Ajoute ce fichier pour les couleurs

class EditFormationPage extends StatefulWidget {
  final Formation formation;
  const EditFormationPage({super.key, required this.formation});

  @override
  State<EditFormationPage> createState() => _EditFormationPageState();
}

class _EditFormationPageState extends State<EditFormationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titreController;
  late TextEditingController descriptionController;
  late TextEditingController lieuController;
  late TextEditingController placesTotalController;
  late TextEditingController contactEmailController;
  DateTime? _dateDebut;
  DateTime? _dateFin;

  @override
  void initState() {
    super.initState();
    titreController = TextEditingController(text: widget.formation.titre);
    descriptionController = TextEditingController(
      text: widget.formation.description,
    );
    lieuController = TextEditingController(text: widget.formation.lieu);
    placesTotalController = TextEditingController(
      text: widget.formation.placesTotal.toString(),
    );
    contactEmailController = TextEditingController(
      text: widget.formation.contactEmail,
    );
    _dateDebut = widget.formation.dateDebut;
    _dateFin = widget.formation.dateFin;
  }

  @override
  void dispose() {
    titreController.dispose();
    descriptionController.dispose();
    lieuController.dispose();
    placesTotalController.dispose();
    contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDebut) async {
    final initialDate =
        isDebut ? _dateDebut ?? DateTime.now() : _dateFin ?? DateTime.now();
    final firstDate = DateTime(2000);
    final lastDate = DateTime(2100);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        if (isDebut) {
          _dateDebut = picked;
        } else {
          _dateFin = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FormationService().updateFormation(widget.formation.id, {
          'titre': titreController.text,
          'description': descriptionController.text,
          'lieu': lieuController.text,
          'places_total': int.tryParse(placesTotalController.text) ?? 0,
          'contact_email': contactEmailController.text,
          'date_debut': _dateDebut?.toIso8601String(),
          'date_fin': _dateFin?.toIso8601String(),
          // à adapter selon ton backend
        });
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la modification : $e')),
        );
      }
    }
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AUFTheme.primary),
      labelStyle: TextStyle(color: AUFTheme.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AUFTheme.primary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AUFTheme.primary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AUFTheme.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AUFTheme.background,
      appBar: AppBar(
        title: Text(
          'Modifier la formation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AUFTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations générales',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AUFTheme.primary,
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: titreController,
                              decoration: _getInputDecoration(
                                'Titre',
                                Icons.title,
                              ),
                              validator:
                                  (v) => v!.isEmpty ? 'Titre requis' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: descriptionController,
                              decoration: _getInputDecoration(
                                'Description',
                                Icons.description,
                              ),
                              maxLines: 3,
                              validator:
                                  (v) =>
                                      v!.isEmpty ? 'Description requise' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Détails de la formation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AUFTheme.primary,
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: lieuController,
                              decoration: _getInputDecoration(
                                'Lieu',
                                Icons.location_on,
                              ),
                              validator:
                                  (v) => v!.isEmpty ? 'Lieu requis' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: placesTotalController,
                              decoration: _getInputDecoration(
                                'Places totales',
                                Icons.group,
                              ),
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      v!.isEmpty
                                          ? 'Nombre de places requis'
                                          : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: contactEmailController,
                              decoration: _getInputDecoration(
                                'Email de contact',
                                Icons.email,
                              ),
                              validator:
                                  (v) => v!.isEmpty ? 'Email requis' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dates',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AUFTheme.primary,
                              ),
                            ),
                            SizedBox(height: 16),
                            ListTile(
                              leading: Icon(
                                Icons.calendar_today,
                                color: AUFTheme.primary,
                              ),
                              title: Text(
                                _dateDebut != null
                                    ? 'Début : ${_dateDebut!.toLocal().toString().split(' ')[0]}'
                                    : 'Date de début non définie',
                              ),
                              trailing: TextButton.icon(
                                onPressed: () => _selectDate(context, true),
                                icon: Icon(Icons.edit_calendar),
                                label: Text('Modifier'),
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.event,
                                color: AUFTheme.primary,
                              ),
                              title: Text(
                                _dateFin != null
                                    ? 'Fin : ${_dateFin!.toLocal().toString().split(' ')[0]}'
                                    : 'Date de fin non définie',
                              ),
                              trailing: TextButton.icon(
                                onPressed: () => _selectDate(context, false),
                                icon: Icon(Icons.edit_calendar),
                                label: Text('Modifier'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AUFTheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Enregistrer les modifications',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
