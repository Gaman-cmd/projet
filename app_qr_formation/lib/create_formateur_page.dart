// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously, deprecated_member_use, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import 'config.dart';

class CreateFormateurPage extends StatefulWidget {
  @override
  State<CreateFormateurPage> createState() => _CreateFormateurPageState();
}

class _CreateFormateurPageState extends State<CreateFormateurPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String nom = '';
  String prenom = '';
  String email = '';
  String password = '';
  bool _obscurePassword = true;
  bool _isLoading = false;

  // AUF theme colors
  final Color aufRed = Color(0xFFA6192E);
  final Color nodeRed = Color(0xFFE63946);
  final Color nodeGreen = Color(0xFF7CB518);
  final Color nodePurple = Color(0xFF6A0DAD);
  final Color nodeYellow = Color(0xFFFFC914);
  final Color nodeBlue = Color(0xFF219EBC);
  final Color nodeGray = Color(0xFFADB5BD);

  Future<void> _createFormateur() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('${AppConfig.apiBaseUrl}/api/register_formateur/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'nom': nom,
            'prenom': prenom,
            'password': password,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Formateur créé avec succès'),
              backgroundColor: nodeGreen,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la création: ${response.body}'),
              backgroundColor: nodeRed,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
            backgroundColor: nodeRed,
          ),
        );
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: aufRed,
        title: Text(
          'Créer un formateur',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo section
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'AUF',
                          style: GoogleFonts.montserrat(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: aufRed,
                          ),
                        ),
                        SizedBox(width: 12),
                        _buildNetworkIcon(),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),

                Text(
                  'Informations du formateur',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 16),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInputField(
                        label: 'Nom',
                        hintText: 'Entrez le nom',
                        icon: Icons.person_outline,
                        validator:
                            (v) => v!.isEmpty ? 'Le nom est requis' : null,
                        onChanged: (v) => nom = v,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        label: 'Prénom',
                        hintText: 'Entrez le prénom',
                        icon: Icons.person_outline,
                        validator:
                            (v) => v!.isEmpty ? 'Le prénom est requis' : null,
                        onChanged: (v) => prenom = v,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        label: 'Email',
                        hintText: 'exemple@domain.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'L\'email est requis';
                          }
                          bool emailValid = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(value);
                          return emailValid ? null : 'Entrez un email valide';
                        },
                        onChanged: (v) => email = v,
                      ),
                      SizedBox(height: 16),
                      _buildPasswordField(),
                      SizedBox(height: 30),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkIcon() {
    return Container(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          // Grey network lines
          CustomPaint(size: Size(40, 40), painter: NetworkPainter(nodeGray)),
          // Colored nodes
          Positioned(top: 5, left: 20, child: _buildNode(nodeRed)),
          Positioned(top: 20, left: 5, child: _buildNode(nodeGreen)),
          Positioned(top: 20, right: 5, child: _buildNode(nodePurple)),
          Positioned(bottom: 5, left: 20, child: _buildNode(nodeYellow)),
          Positioned(bottom: 12, right: 12, child: _buildNode(nodeBlue)),
        ],
      ),
    );
  }

  Widget _buildNode(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required IconData icon,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        onChanged: onChanged,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: aufRed),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[700]),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        obscureText: _obscurePassword,
        onChanged: (v) => password = v,
        validator: (v) {
          if (v!.isEmpty) {
            return 'Le mot de passe est requis';
          }
          if (v.length < 6) {
            return 'Le mot de passe doit contenir au moins 6 caractères';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Mot de passe',
          hintText: '••••••••',
          prefixIcon: Icon(Icons.lock_outline, color: aufRed),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[700]),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createFormateur,
        style: ElevatedButton.styleFrom(
          backgroundColor: aufRed,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : Text(
                  'Créer le formateur',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}

class NetworkPainter extends CustomPainter {
  final Color lineColor;

  NetworkPainter(this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    // Draw simple network connections
    final path = Path();

    // Center point
    final center = Offset(size.width / 2, size.height / 2);

    // Top node
    path.moveTo(center.dx, center.dy);
    path.lineTo(center.dx, 5);

    // Left node
    path.moveTo(center.dx, center.dy);
    path.lineTo(5, center.dy);

    // Right node
    path.moveTo(center.dx, center.dy);
    path.lineTo(size.width - 5, center.dy);

    // Bottom node
    path.moveTo(center.dx, center.dy);
    path.lineTo(center.dx, size.height - 5);

    // Bottom right node
    path.moveTo(center.dx, center.dy);
    path.lineTo(size.width - 12, size.height - 12);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
