// ignore_for_file: file_names, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'add_formation_page.dart';
import 'formation_detail_page.dart';
import 'models/formation_model.dart';
import 'services/formation_service.dart';
import 'package:google_fonts/google_fonts.dart';

// Définition de la palette de couleurs inspirée du logo AUF
class AUFTheme {
  static const Color primaryColor = Color(0xFFBE0028); // Rouge AUF
  static const Color secondaryColor = Color(0xFF2E2E2E); // Gris foncé
  static const Color accentGreen = Color(0xFF96C93D); // Vert
  static const Color accentYellow = Color(0xFFFFD200); // Jaune
  static const Color accentBlue = Color(0xFF1E90FF); // Bleu
  static const Color accentPurple = Color(0xFF8E44AD); // Violet
  static const Color lightGrey = Color(0xFFF5F5F5); // Gris clair pour le fond
  static const Color white = Color(0xFFFFFFFF); // Blanc
}

class FormationsPage extends StatefulWidget {
  const FormationsPage({super.key});

  @override
  _FormationsPageState createState() => _FormationsPageState();
}

class _FormationsPageState extends State<FormationsPage> {
  final FormationService _formationService = FormationService();
  List<Formation> _formations = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'tous'; // filtre par défaut

  @override
  void initState() {
    super.initState();
    _loadFormations();
  }

  Future<void> _loadFormations() async {
    try {
      setState(() => _isLoading = true);
      final formations = await _formationService.getFormations();
      setState(() {
        _formations = formations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Formation> get _filteredFormations {
    if (_selectedFilter == 'tous') {
      return _formations;
    }
    return _formations.where((formation) {
      final statut = _getStatut(formation.dateDebut, formation.dateFin);
      return statut == _selectedFilter;
    }).toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filtrer par statut',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AUFTheme.secondaryColor,
                ),
              ),
              SizedBox(height: 20),
              _buildFilterOption('tous', 'Toutes les formations'),
              _buildFilterOption('a_venir', 'À venir'),
              _buildFilterOption('en_cours', 'En cours'),
              _buildFilterOption('terminee', 'Terminées'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String value, String label) {
    final bool isSelected = _selectedFilter == value;

    Color getColor() {
      switch (value) {
        case 'a_venir':
          return AUFTheme.accentBlue;
        case 'en_cours':
          return AUFTheme.accentGreen;
        case 'terminee':
          return Colors.grey;
        default:
          return AUFTheme.primaryColor;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color:
                isSelected ? getColor().withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? getColor() : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isSelected ? getColor() : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: getColor()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormationCard(Formation formation) {
    final statut = _getStatut(formation.dateDebut, formation.dateFin);

    // Couleur en fonction du statut
    Color statusColor;
    switch (statut) {
      case 'a_venir':
        statusColor = AUFTheme.accentBlue;
        break;
      case 'en_cours':
        statusColor = AUFTheme.accentGreen;
        break;
      case 'terminee':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    // Calcul du pourcentage de places réservées
    final int total = formation.placesTotal;
    final int acceptes = formation.nombreParticipantsAcceptes;
    final double percentage = (total > 0) ? (acceptes / total) * 100 : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AUFTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => FormationDetailPage(formationId: formation.id),
            ),
          );
        },
        child: Column(
          children: [
            // Bannière de statut
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    _getStatusLabel(statut),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Titre de la formation
            Text(
              formation.titre,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AUFTheme.secondaryColor,
              ),
            ),
            SizedBox(height: 8),

            // Description
            Text(
              formation.description,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16),

            // Informations de date et lieu
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AUFTheme.primaryColor,
                ),
                SizedBox(width: 6),
                Text(
                  _formatDate(formation.dateDebut),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AUFTheme.primaryColor),
                SizedBox(width: 6),
                Text(
                  formation.lieu,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Barre de progression des places
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Places réservées',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '$acceptes/$total',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            acceptes >= total * 0.8
                                ? AUFTheme.primaryColor
                                : AUFTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0 ? acceptes / total : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      acceptes >= total * 0.8
                          ? AUFTheme.primaryColor
                          : AUFTheme.accentGreen,
                    ),
                    minHeight: 6,
                  ),
                ),
                SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${percentage.toStringAsFixed(0)}% places réservées',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String statut) {
    switch (statut) {
      case 'a_venir':
        return 'À venir';
      case 'en_cours':
        return 'En cours';
      case 'terminee':
        return 'Terminée';
      default:
        return 'Inconnu';
    }
  }

  String _formatDate(DateTime date) {
    // Liste des mois en français
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getStatut(DateTime dateDebut, DateTime dateFin) {
    final now = DateTime.now();
    if (now.isBefore(dateDebut)) {
      return 'a_venir';
    } else if (now.isAfter(dateFin)) {
      return 'terminee';
    } else {
      return 'en_cours';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AUFTheme.lightGrey,
      appBar: AppBar(
        backgroundColor: AUFTheme.primaryColor,
        elevation: 0,
        title: Text(
          'Formations',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AUFTheme.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AUFTheme.white),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AUFTheme.primaryColor,
                  ),
                ),
              )
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AUFTheme.primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AUFTheme.secondaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _error!,
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadFormations,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AUFTheme.primaryColor,
                        foregroundColor: AUFTheme.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: Icon(Icons.refresh),
                      label: Text(
                        'Réessayer',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )
              : _filteredFormations.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'Aucune formation trouvée',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AUFTheme.secondaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Essayez de modifier les filtres ou revenez plus tard.',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadFormations,
                color: AUFTheme.primaryColor,
                child: ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: _filteredFormations.length,
                  itemBuilder:
                      (context, index) =>
                          _buildFormationCard(_filteredFormations[index]),
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFormationPage()),
          ).then((_) {
            // Recharger les formations après l'ajout
            _loadFormations();
          });
        },
        backgroundColor: AUFTheme.primaryColor,
        icon: Icon(Icons.add, color: AUFTheme.white),
        label: Text(
          'Nouvelle formation',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: AUFTheme.white,
          ),
        ),
      ),
    );
  }
}
