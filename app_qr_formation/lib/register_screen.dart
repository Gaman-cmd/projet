// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';
import 'package:intl/intl.dart';

// Couleurs du logo AUF
class AUFColors {
  static const Color primaryRed = Color(0xFFB01C2E);
  static const Color accentRed = Color(0xFFE63E2C);
  static const Color accentGreen = Color(0xFF97C93D);
  static const Color accentPurple = Color(0xFF7A2A90);
  static const Color accentYellow = Color(0xFFFDD500);
  static const Color accentBlue = Color(0xFF1A9BD7);
  static const Color lightGrey = Color(0xFFBCBDBE);
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _lieuNaissanceController = TextEditingController();
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Liste des couleurs d'accent pour alterner sur les champs
  final List<Color> _accentColors = [
    AUFColors.accentRed,
    AUFColors.accentGreen,
    AUFColors.accentPurple,
    AUFColors.accentYellow,
    AUFColors.accentBlue,
  ];
  int _colorIndex = 0;

  // Obtenir la prochaine couleur d'accent
  Color _getNextAccentColor() {
    Color color = _accentColors[_colorIndex];
    _colorIndex = (_colorIndex + 1) % _accentColors.length;
    return color;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AUFColors.primaryRed,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateNaissanceController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final result = await AuthService().register(
          _emailController.text,
          _passwordController.text,
          _nomController.text,
          _prenomController.text,
          _telephoneController.text,
          _dateNaissanceController.text,
          _lieuNaissanceController.text,
        );

        if (result['status']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inscription réussie ! Connectez-vous maintenant.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          setState(() {
            _errorMessage = result['message'];
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AUFColors.primaryRed),
        title: Text(
          'Inscription',
          style: TextStyle(
            color: AUFColors.primaryRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Veuillez remplir les informations suivantes',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 30),
                _buildInputField(
                  controller: _nomController,
                  label: 'Nom',
                  icon: Icons.person_outline,
                  validator:
                      (val) => val!.isEmpty ? 'Ce champ est requis' : null,
                ),
                _buildInputField(
                  controller: _prenomController,
                  label: 'Prénom',
                  icon: Icons.person_outline,
                  validator:
                      (val) => val!.isEmpty ? 'Ce champ est requis' : null,
                ),
                _buildInputField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val!.isEmpty) return 'Ce champ est requis';
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(val)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                _buildPasswordField(),
                _buildInputField(
                  controller: _telephoneController,
                  label: 'Téléphone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator:
                      (val) => val!.isEmpty ? 'Ce champ est requis' : null,
                ),
                _buildDateField(context),
                _buildInputField(
                  controller: _lieuNaissanceController,
                  label: 'Lieu de naissance',
                  icon: Icons.location_city_outlined,
                  validator:
                      (val) => val!.isEmpty ? 'Ce champ est requis' : null,
                ),
                SizedBox(height: 30),
                if (_errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AUFColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AUFColors.primaryRed),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: AUFColors.primaryRed),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
                _buildRegisterButton(),
                SizedBox(height: 30),
                _buildLoginRedirect(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    // Utiliser une couleur d'accent différente pour chaque champ
    final accentColor = _getNextAccentColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        cursorColor: AUFColors.primaryRed,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
          prefixIcon: Icon(icon, color: accentColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AUFColors.lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AUFColors.primaryRed, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AUFColors.primaryRed, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    // Utiliser une couleur d'accent pour le champ de mot de passe
    final accentColor = _getNextAccentColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        cursorColor: AUFColors.primaryRed,
        validator: (val) {
          if (val!.isEmpty) return 'Ce champ est requis';
          if (val.length < 6) {
            return 'Le mot de passe doit contenir au moins 6 caractères';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Mot de passe',
          labelStyle: TextStyle(color: Colors.black54),
          prefixIcon: Icon(Icons.lock_outline, color: accentColor),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AUFColors.lightGrey,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AUFColors.lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AUFColors.primaryRed, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AUFColors.primaryRed, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    // Utiliser une couleur d'accent pour le champ de date
    final accentColor = _getNextAccentColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: _dateNaissanceController,
        readOnly: true,
        validator: (val) => val!.isEmpty ? 'Ce champ est requis' : null,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          labelText: 'Date de naissance',
          labelStyle: TextStyle(color: Colors.black54),
          prefixIcon: Icon(Icons.calendar_today_outlined, color: accentColor),
          suffixIcon: Icon(Icons.arrow_drop_down, color: AUFColors.lightGrey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AUFColors.lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AUFColors.primaryRed, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AUFColors.primaryRed, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AUFColors.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  "S'inscrire",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  Widget _buildLoginRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Déjà inscrit ? ', style: TextStyle(color: Colors.black54)),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Text(
            'Se connecter',
            style: TextStyle(
              color: AUFColors.primaryRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
