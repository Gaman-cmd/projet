// ignore_for_file: use_super_parameters, file_names, deprecated_member_use, sized_box_for_whitespace, unused_local_variable

import 'package:flutter/material.dart';
//import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/participant_model.dart';
import '../services/formation_service.dart';
import 'code_barre.dart';

class ParticipantDetailPage extends StatefulWidget {
  final Participant participant;
  const ParticipantDetailPage({Key? key, required this.participant})
    : super(key: key);

  @override
  State<ParticipantDetailPage> createState() => _ParticipantDetailPageState();
}

class _ParticipantDetailPageState extends State<ParticipantDetailPage> {
  List formations = [];
  bool isLoading = true;

  // AUF theme colors
  final Color aufRed = Color(0xFFA6192E);
  final Color nodeRed = Color(0xFFE63946);
  final Color nodeGreen = Color(0xFF7CB518);
  final Color nodePurple = Color(0xFF6A0DAD);
  final Color nodeYellow = Color(0xFFFFC914);
  final Color nodeBlue = Color(0xFF219EBC);
  final Color nodeGray = Color(0xFFADB5BD);
  final Color bgColor = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _loadFormations();
  }

  Future<void> _loadFormations() async {
    try {
      final response = await FormationService().getFormationsByParticipant(
        widget.participant.id,
      );
      setState(() {
        formations = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.participant;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${p.prenom} ${p.nom}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: aufRed,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with network background
            _buildHeader(p),

            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations personnelles title
                  Row(
                    children: [
                      Icon(Icons.person, color: aufRed),
                      SizedBox(width: 8),
                      Text(
                        'Informations personnelles',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Infos participant
                  _buildInfoCard(p),

                  SizedBox(height: 24),

                  // Formations title
                  Row(
                    children: [
                      Icon(Icons.school, color: aufRed),
                      SizedBox(width: 8),
                      Text(
                        'Formations inscrites',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Formations list
                  _buildFormationsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Participant p) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: aufRed,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Network pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: NetworkBackgroundPainter(Colors.white.withOpacity(0.1)),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo and name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AUF',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    _buildNetworkIcon(),
                  ],
                ),

                SizedBox(height: 16),

                // Participant name
                Text(
                  '${p.prenom} ${p.nom}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 4),

                // Email
                Text(
                  p.email,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Participant p) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.badge, 'Nom complet', '${p.prenom} ${p.nom}'),
            _divider(),
            _infoRow(Icons.email, 'Email', p.email),
            _divider(),
            _infoRow(Icons.phone, 'Téléphone', p.telephone),
            _divider(),
            _infoRow(Icons.cake, 'Date de naissance', p.dateNaissance ?? '-'),
            _divider(),
            _infoRow(
              Icons.location_on,
              'Lieu de naissance',
              p.lieuNaissance ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormationsList() {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: CircularProgressIndicator(color: aufRed),
        ),
      );
    }

    if (formations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.school_outlined, size: 50, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Aucune formation inscrite',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: formations.length,
      itemBuilder: (context, index) {
        final f = formations[index];
        final inscription = f['inscription'];
        final statut = inscription != null ? inscription['statut'] : null;
        final qrCode = inscription != null ? inscription['qr_code'] : null;
        final formationDate =
            '${f['date_debut']?.substring(0, 10) ?? ''} - ${f['date_fin']?.substring(0, 10) ?? ''}';

        // Status color
        Color statusColor;
        IconData statusIcon;
        String statusText;

        switch (statut) {
          case 'accepte':
            statusColor = nodeGreen;
            statusIcon = Icons.check_circle;
            statusText = 'Accepté';
            break;
          case 'en_attente':
            statusColor = nodeYellow;
            statusIcon = Icons.hourglass_empty;
            statusText = 'En attente';
            break;
          case 'refuse':
            statusColor = nodeRed;
            statusIcon = Icons.cancel;
            statusText = 'Refusé';
            break;
          default:
            statusColor = Colors.grey;
            statusIcon = Icons.help_outline;
            statusText = 'Non défini';
        }

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                title: Text(
                  f['titre'] ?? 'Sans titre',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      f['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: aufRed),
                        SizedBox(width: 4),
                        Text(
                          formationDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status and QR button row
              Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // QR Code button if accepted
                    if (statut == 'accepte' && qrCode != null)
                      OutlinedButton.icon(
                        onPressed: () {
                          final p = widget.participant;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CodeBarrePage(
                                    name: '${p.prenom} ${p.nom}',
                                    email: p.email,
                                    phoneNumber: p.telephone,
                                    dateOfBirth: p.dateNaissance ?? '',
                                    lieuNaissance: p.lieuNaissance ?? '',
                                    formationTitre: f['titre'] ?? '',
                                    formationDate: formationDate,
                                    qrCode: qrCode,
                                  ),
                            ),
                          );
                        },
                        icon: Icon(Icons.qr_code),
                        label: Text('Afficher QR'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: aufRed,
                          side: BorderSide(color: aufRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: aufRed, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(color: Colors.grey[200], thickness: 1),
    );
  }

  Widget _buildNetworkIcon() {
    return Container(
      width: 24,
      height: 24,
      child: Stack(
        children: [
          // Grey network lines
          CustomPaint(
            size: Size(24, 24),
            painter: NetworkPainter(Colors.white.withOpacity(0.7)),
          ),
          // Colored nodes
          Positioned(top: 3, left: 12, child: _buildNode(nodeRed)),
          Positioned(top: 12, left: 3, child: _buildNode(nodeGreen)),
          Positioned(top: 12, right: 3, child: _buildNode(nodePurple)),
          Positioned(bottom: 3, left: 12, child: _buildNode(nodeYellow)),
          Positioned(bottom: 7, right: 7, child: _buildNode(nodeBlue)),
        ],
      ),
    );
  }

  Widget _buildNode(Color color) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Draw simple network connections
    final path = Path();

    // Center point
    final center = Offset(size.width / 2, size.height / 2);

    // Top node
    path.moveTo(center.dx, center.dy);
    path.lineTo(center.dx, 3);

    // Left node
    path.moveTo(center.dx, center.dy);
    path.lineTo(3, center.dy);

    // Right node
    path.moveTo(center.dx, center.dy);
    path.lineTo(size.width - 3, center.dy);

    // Bottom node
    path.moveTo(center.dx, center.dy);
    path.lineTo(center.dx, size.height - 3);

    // Bottom right node
    path.moveTo(center.dx, center.dy);
    path.lineTo(size.width - 7, size.height - 7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NetworkBackgroundPainter extends CustomPainter {
  final Color lineColor;

  NetworkBackgroundPainter(this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final nodePaint =
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.fill;

    // Create a network pattern
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Draw some random connections
        if ((i + j) % 2 == 0) {
          final startX = i * size.width / 8;
          final startY = j * size.height / 8;
          final endX = startX + size.width / 8;
          final endY = startY + size.height / 8;

          // Draw a node
          canvas.drawCircle(Offset(startX, startY), 1.5, nodePaint);

          // Connect to some neighbors
          if (i < 7) {
            canvas.drawLine(
              Offset(startX, startY),
              Offset(startX + size.width / 8, startY),
              paint,
            );
          }

          if (j < 7) {
            canvas.drawLine(
              Offset(startX, startY),
              Offset(startX, startY + size.height / 8),
              paint,
            );
          }

          if (i < 7 && j < 7) {
            canvas.drawLine(
              Offset(startX, startY),
              Offset(startX + size.width / 8, startY + size.height / 8),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
