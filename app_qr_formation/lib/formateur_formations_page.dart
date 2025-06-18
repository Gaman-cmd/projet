// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'models/formation_model.dart';
import 'formation_detail_page.dart';
import 'formateur_home_page.dart';

class FormateurFormationsPage extends StatelessWidget {
  final List<Formation> formations;
  final bool isLoading;

  const FormateurFormationsPage({
    super.key,
    required this.formations,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  appBar: AppBar(
        backgroundColor: AUFColors.primary,
        title: const Text(
          'Formations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ), */
      backgroundColor: AUFColors.background,
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AUFColors.primary),
              )
              : ListView(
                padding: const EdgeInsets.all(20),
                children:
                    formations.isEmpty
                        ? [
                          Container(
                            margin: const EdgeInsets.only(top: 40),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AUFColors.primary,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Aucune formation associée.",
                                  style: TextStyle(
                                    color: AUFColors.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                        : formations
                            .map((f) => _buildFormationCard(context, f))
                            .toList(),
              ),
    );
  }

  Widget _buildFormationCard(BuildContext context, Formation formation) {
    final List<Color> themeColors = [
      AUFColors.accent1,
      AUFColors.accent2,
      AUFColors.accent3,
      AUFColors.accent4,
    ];
    final Color themeColor = themeColors[formation.id % themeColors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormationDetailPage(formationId: formation.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.school, color: themeColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formation.titre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AUFColors.secondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: themeColor),
                  const SizedBox(width: 6),
                  Text(
                    'Du ${_formatDate(formation.dateDebut)} au ${_formatDate(formation.dateFin)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: themeColor),
                  const SizedBox(width: 6),
                  Text(
                    formation.lieu,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
