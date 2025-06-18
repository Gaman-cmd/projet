// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/formation_service.dart';
import 'models/user_model.dart';

class AddFormationPage extends StatefulWidget {
  const AddFormationPage({super.key});

  @override
  _AddFormationPageState createState() => _AddFormationPageState();
}

class _AddFormationPageState extends State<AddFormationPage> {
  final Color primaryColor = const Color(0xFFA6092B); // Rouge AUF
  final Color accentColor = const Color(0xFF2196F3); // Bleu
  final Color greenColor = const Color(0xFF8BC34A); // Vert
  final Color purpleColor = const Color(0xFF9C27B0); // Violet
  final Color yellowColor = const Color(0xFFFFC107); // Jaune

  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lieuController = TextEditingController();
  final _placesTotalController = TextEditingController();
  final _contactEmailController = TextEditingController();
  DateTime? _dateDebut;
  DateTime? _dateFin;

  final FormationService _formationService = FormationService();

  File? _imageFile;
  String? _imagePath; // Nouvelle variable pour stocker le chemin/URL de l'image
  final ImagePicker _picker = ImagePicker();

  User? _selectedFormateur;
  List<User> _formateurs = [];

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imagePath = pickedFile.path; // Stocke le chemin/URL
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
      );
    }
  }

  Future<void> _submitFormation() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _formationService.uploadImage(_imageFile!);
        }

        await _formationService.addFormation({
          'titre': _titreController.text,
          'description': _descriptionController.text,
          'date_debut': _dateDebut?.toIso8601String(),
          'date_fin': _dateFin?.toIso8601String(),
          'lieu': _lieuController.text,
          'places_total': int.parse(_placesTotalController.text),
          'contact_email': _contactEmailController.text,
          'image_url': imageUrl,
          'statut': 'a_venir',
          'formateur_id': _selectedFormateur?.id,
        });
        Navigator.pop(context);
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
  void initState() {
    super.initState();
    _loadFormateurs();
  }

  Future<void> _loadFormateurs() async {
    try {
      final formateurs = await FormationService().getFormateurs();
      setState(() {
        _formateurs = formateurs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des formateurs : $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nouvelle Formation',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, Colors.white],
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
                          color: primaryColor,
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
                      SizedBox(height: 16),
                      DropdownButtonFormField<User>(
                        value: _selectedFormateur,
                        items:
                            _formateurs.map((formateur) {
                              return DropdownMenuItem<User>(
                                value: formateur,
                                child: Text(
                                  '${formateur.prenom} ${formateur.nom}',
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFormateur = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Formateur',
                          prefixIcon: Icon(Icons.person, color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: primaryColor.withOpacity(0.2),
                            ),
                          ),
                          filled: true,
                          fillColor: primaryColor.withOpacity(0.05),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner un formateur';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      _buildDateSelector(context),
                      SizedBox(height: 16),
                      _buildImageSelector(),
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
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: primaryColor.withOpacity(0.05),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDateRow(
              isStartDate: true,
              date: _dateDebut,
              onTap: () => _selectDate(context, true),
            ),
            Divider(color: primaryColor.withOpacity(0.2)),
            _buildDateRow(
              isStartDate: false,
              date: _dateFin,
              onTap: () => _selectDate(context, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow({
    required bool isStartDate,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Icon(Icons.calendar_today, color: primaryColor),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            date == null
                ? '${isStartDate ? "Date de début" : "Date de fin"} : Non sélectionnée'
                : '${isStartDate ? "Date de début" : "Date de fin"} : ${date.toLocal()}'
                    .split(' ')[0],
            style: TextStyle(fontSize: 16),
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Sélectionner'),
        ),
      ],
    );
  }

  Widget _buildImageSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image de la formation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child:
                      _imagePath != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            // Utilisation conditionnelle pour mobile/web
                            child:
                                kIsWeb
                                    ? Image.network(
                                      _imagePath!,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.file(
                                      File(_imagePath!),
                                      fit: BoxFit.cover,
                                    ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.blue.shade700,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Cliquez pour ajouter une image',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
