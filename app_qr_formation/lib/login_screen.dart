// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'formateur_home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final result = await AuthService().login(email, password);

    if (result['status'] && result['user'] != null) {
      final user = result['user'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('user_id', user['id']);
      if (user['role'] == 'admin') {
        prefs.setInt('admin_id', user['id']);
      }
      if (user['role'] == 'participant') {
        prefs.setInt('participant_id', user['id']);
      }
      if (user['role'] == 'formateur') {
        prefs.setInt('formateur_id', user['id']);
      }
      prefs.setString('nom', user['nom']);
      prefs.setString('prenom', user['prenom']);
      prefs.setString('email', user['email']);
      prefs.setString('telephone', user['telephone'] ?? '');
      prefs.setString('dateNaissance', user['date_naissance'] ?? '');
      prefs.setString('lieuNaissance', user['lieu_naissance'] ?? '');
      prefs.setString('role', user['role']);

      if (user['role'] == 'admin') {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (user['role'] == 'participant') {
        Navigator.pushReplacementNamed(context, '/participant_home');
      } else if (user['role'] == 'formateur') {
        prefs.setInt('formateur_id', user['id']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FormateurHomePage()),
        );
      } else {
        setState(() {
          _errorMessage = "Rôle non autorisé.";
        });
      }
    } else {
      setState(() {
        _errorMessage = result['message'] ?? "Erreur de connexion";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background pattern
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xFFAA0C2F).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Color(0xFFAA0C2F).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Connection nodes pattern (right side decoration)
          Positioned(
            top: size.height * 0.15,
            right: 20,
            child: _buildNodesPattern(),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: size.width > 600 ? 500 : size.width * 0.9,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "AUF",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFAA0C2F),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Heading
                    Text(
                      "Connexion",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_errorMessage != null) SizedBox(height: 16),

                    // Email field
                    TextField(
                      controller: _emailController,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Email ou identifiant",
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Color(0xFFAA0C2F),
                        ),
                        filled: true,
                        fillColor: Color(0xFFF8F9FA),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFFAA0C2F),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Mot de passe",
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Color(0xFFAA0C2F),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Color(0xFF888888),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Color(0xFFF8F9FA),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFFAA0C2F),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Action à définir plus tard
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF555555),
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Mot de passe oublié ?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFAA0C2F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Se connecter",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Sign up
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          "Vous n'avez pas de compte ?",
                          style: TextStyle(color: Color(0xFF777777)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFFAA0C2F),
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "Créer un compte",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to create the node pattern inspired by the logo
  Widget _buildNodesPattern() {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(painter: NodePatternPainter()),
    );
  }
}

// Custom painter for the network nodes pattern
class NodePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linesPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    // Define node positions
    final centerNode = Offset(size.width / 2, size.height / 2);
    final topNode = Offset(size.width / 2, size.height * 0.15);
    final rightNode = Offset(size.width * 0.85, size.height / 2);
    final bottomNode = Offset(size.width / 2, size.height * 0.85);
    final leftNode = Offset(size.width * 0.15, size.height / 2);

    // Draw connections
    canvas.drawLine(centerNode, topNode, linesPaint);
    canvas.drawLine(centerNode, rightNode, linesPaint);
    canvas.drawLine(centerNode, bottomNode, linesPaint);
    canvas.drawLine(centerNode, leftNode, linesPaint);
    canvas.drawLine(topNode, rightNode, linesPaint);
    canvas.drawLine(rightNode, bottomNode, linesPaint);
    canvas.drawLine(bottomNode, leftNode, linesPaint);
    canvas.drawLine(leftNode, topNode, linesPaint);

    // Draw nodes
    final centerNodePaint =
        Paint()
          ..color = Color(0xFFAA0C2F)
          ..style = PaintingStyle.fill;
    final topNodePaint =
        Paint()
          ..color = Color(0xFF34C759) // Green
          ..style = PaintingStyle.fill;
    final rightNodePaint =
        Paint()
          ..color = Color(0xFF8E44AD) // Purple
          ..style = PaintingStyle.fill;
    final bottomNodePaint =
        Paint()
          ..color = Color(0xFF3498DB) // Blue
          ..style = PaintingStyle.fill;
    final leftNodePaint =
        Paint()
          ..color = Color(0xFFF1C40F) // Yellow
          ..style = PaintingStyle.fill;

    canvas.drawCircle(centerNode, 6, centerNodePaint);
    canvas.drawCircle(topNode, 6, topNodePaint);
    canvas.drawCircle(rightNode, 6, rightNodePaint);
    canvas.drawCircle(bottomNode, 6, bottomNodePaint);
    canvas.drawCircle(leftNode, 6, leftNodePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
