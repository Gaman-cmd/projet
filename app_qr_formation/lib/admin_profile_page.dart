import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_formateur_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  String nom = '';
  String prenom = '';
  String email = '';
  int? adminId;
  bool _isLoading = true;

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Couleurs AUF
  final Color aufRed = const Color(0xFFB2001A);
  final Color aufBlue = const Color(0xFF1A9CD9);
  final Color aufGreen = const Color(0xFF92C020);
  final Color aufPurple = const Color(0xFF7A2A90);
  final Color aufYellow = const Color(0xFFFFD100);

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        nom = prefs.getString('nom') ?? '';
        prenom = prefs.getString('prenom') ?? '';
        email = prefs.getString('email') ?? '';
        adminId = prefs.getInt('admin_id');
        _nomController.text = nom;
        _prenomController.text = prenom;
        _emailController.text = email;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement du profil: ${e.toString()}'),
          backgroundColor: aufRed,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() && adminId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.put(
          Uri.parse('http://127.0.0.1:8000/api/modifier_profil/$adminId/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nom': _nomController.text,
            'prenom': _prenomController.text,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          // Mettre à jour les valeurs locales
          setState(() {
            nom = _nomController.text;
            prenom = _prenomController.text;
            _isEditing = false;
          });

          // Mettre à jour SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('nom', nom);
          prefs.setString('prenom', prenom);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profil mis à jour avec succès'),
              backgroundColor: aufGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la mise à jour: ${response.body}'),
              backgroundColor: aufRed,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: ${e.toString()}'),
            backgroundColor: aufRed,
          ),
        );
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _nomController.text = nom;
      _prenomController.text = prenom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: aufRed,
        elevation: 0,
        title: const Text(
          'Profil Administrateur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(aufRed),
                ),
              )
              : Column(
                children: [
                  // En-tête du profil
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: aufRed,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: aufRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$prenom $nom',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Formulaire de profil
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informations personnelles',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Nom
                              TextFormField(
                                controller: _nomController,
                                enabled: _isEditing,
                                decoration: InputDecoration(
                                  labelText: 'Nom',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: _isEditing ? aufRed : Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: aufRed,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor:
                                      _isEditing
                                          ? Colors.white
                                          : Colors.grey[100],
                                ),
                                validator:
                                    (v) => v!.isEmpty ? 'Nom requis' : null,
                              ),
                              const SizedBox(height: 16),

                              // Prénom
                              TextFormField(
                                controller: _prenomController,
                                enabled: _isEditing,
                                decoration: InputDecoration(
                                  labelText: 'Prénom',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: _isEditing ? aufRed : Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: aufRed,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor:
                                      _isEditing
                                          ? Colors.white
                                          : Colors.grey[100],
                                ),
                                validator:
                                    (v) => v!.isEmpty ? 'Prénom requis' : null,
                              ),
                              const SizedBox(height: 16),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Actions
                              if (_isEditing)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.save),
                                        label: const Text('Enregistrer'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: aufGreen,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: _saveProfile,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.cancel),
                                        label: const Text('Annuler'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey[700],
                                          side: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: _cancelEditing,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text(
                                          'Modifier mon profil',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: aufBlue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isEditing = true;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.person_add),
                                        label: const Text(
                                          'Ajouter un formateur',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: aufPurple,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      CreateFormateurPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
