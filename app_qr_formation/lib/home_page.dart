// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Formation.dart';
import 'config.dart';
import 'models/participant_model.dart';
import 'models/formation_model.dart';
import 'participants_page.dart';
import 'services/formation_service.dart';
import 'services/participant_service.dart';
import 'admin_profile_page.dart';

// Définition des couleurs AUF
class AUFTheme {
  static const Color primary = Color(0xFFB01031);
  static const Color secondary = Color(0xFF333333);
  static const Color accent1 = Color(0xFF2E9CCA);
  static const Color accent2 = Color(0xFFD6C909);
  static const Color accent3 = Color(0xFF82C341);
  static const Color accent4 = Color(0xFF8E44AD);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    _AccueilPageContent(),
    FormationsPage(),
    ParticipantsPage(),
    AdminProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AUFTheme.cardColor,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_rounded),
              label: 'Formations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'Participants',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: AUFTheme.primary,
          unselectedItemColor: AUFTheme.textSecondary,
          onTap: onTabTapped,
        ),
      ),
    );
  }
}

// Contenu modernisé de la page d'accueil
class _AccueilPageContent extends StatefulWidget {
  @override
  __AccueilPageContentState createState() => __AccueilPageContentState();
}

class __AccueilPageContentState extends State<_AccueilPageContent> {
  final FormationService _formationService = FormationService();
  final ParticipantService _participantService = ParticipantService();
  List<Formation> _formations = [];
  List<Participant> _participants = [];
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadFormations();
    _loadParticipants();
    _loadRecentActivities();
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

  Future<void> _loadParticipants() async {
    try {
      final participants = await _participantService.getAllParticipants();
      setState(() {
        _participants = participants;
      });
    } catch (e) {
      // Gestion des erreurs
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/activities/recent/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _recentActivities = List<Map<String, dynamic>>.from(
            data.map(
              (activity) => {
                'type': activity['type'] ?? '',
                'title': activity['title'] ?? '',
                'description': activity['description'] ?? '',
                'created_at':
                    activity['created_at'] != null
                        ? DateTime.parse(activity['created_at'])
                        : DateTime.now(),
              },
            ),
          );
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des activités: $e');
      setState(() {
        _recentActivities = [];
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AUFTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AUFTheme.primary,
        title: Row(
          children: [
            Text(
              'QR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              ' APP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadFormations();
              _loadParticipants();
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Action pour les notifications
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AUFTheme.primary),
                ),
              )
              : _error != null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AUFTheme.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Erreur : $_error',
                      style: TextStyle(color: AUFTheme.textSecondary),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AUFTheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        _loadFormations();
                        _loadParticipants();
                      },
                      child: Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                color: AUFTheme.primary,
                onRefresh: () async {
                  try {
                    await Future.wait([
                      _loadFormations(),
                      _loadParticipants(),
                      _loadRecentActivities(),
                    ]);
                  } catch (e) {
                    _showError('Erreur lors du rafraîchissement');
                  }
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildWelcomeSection(),
                      SizedBox(height: 24),
                      _buildStatsSection(),
                      SizedBox(height: 24),
                      _buildFormationsSection(),
                      SizedBox(height: 16),
                      _buildRecentActivitySection(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AUFTheme.primary, AUFTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AUFTheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue sur le tableau de bord',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Gérez vos formations et participants en toute simplicité',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AUFTheme.textPrimary,
            ),
          ),
        ),
        Row(
          children: [
            _buildStatCard(
              'Formations',
              '${_formations.length}',
              Icons.school_rounded,
              AUFTheme.accent1,
            ),
            SizedBox(width: 16),
            _buildStatCard(
              'Participants',
              '${_participants.length}',
              Icons.people_alt_rounded,
              AUFTheme.accent3,
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              'En cours',
              '${_getActiveFormations()}',
              Icons.event_available_rounded,
              AUFTheme.accent2,
            ),
            SizedBox(width: 16),
            _buildStatCard(
              'Complétées',
              '${_getCompletedFormations()}',
              Icons.check_circle_outline_rounded,
              AUFTheme.accent4,
            ),
          ],
        ),
      ],
    );
  }

  int _getActiveFormations() {
    final now = DateTime.now();
    return _formations
        .where(
          (f) =>
              f.dateDebut.isAfter(now) ||
              (f.dateFin != null && f.dateFin.isAfter(now)),
        )
        .length;
  }

  int _getCompletedFormations() {
    final now = DateTime.now();
    return _formations
        .where((f) => f.dateFin != null && f.dateFin.isBefore(now))
        .length;
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AUFTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AUFTheme.textSecondary, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AUFTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Formations récentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AUFTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                final homePageState =
                    context.findAncestorStateOfType<_HomePageState>();
                if (homePageState != null) {
                  homePageState.onTabTapped(1);
                }
              },
              style: TextButton.styleFrom(foregroundColor: AUFTheme.primary),
              child: Row(
                children: [
                  Text('Voir tout'),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _formations.length > 3 ? 3 : _formations.length,
          itemBuilder: (context, index) {
            final formation = _formations[index];
            return _buildFormationCard(formation);
          },
        ),
      ],
    );
  }

  Widget _buildFormationCard(Formation formation) {
    final now = DateTime.now();
    String status;
    Color statusColor;

    if (formation.dateDebut.isAfter(now)) {
      status = 'À venir';
      statusColor = AUFTheme.accent2;
    } else if (formation.dateFin != null && formation.dateFin.isBefore(now)) {
      status = 'Terminée';
      statusColor = AUFTheme.accent4;
    } else {
      status = 'En cours';
      statusColor = AUFTheme.accent3;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AUFTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                formation.titre,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AUFTheme.textSecondary,
              ),
              SizedBox(width: 4),
              Text(
                _formatDate(formation.dateDebut),
                style: TextStyle(color: AUFTheme.textSecondary, fontSize: 13),
              ),
              SizedBox(width: 16),
              Icon(Icons.people, size: 16, color: AUFTheme.textSecondary),
              SizedBox(width: 4),
              Text(
                '${formation.nombreParticipantsAcceptes}/${formation.placesTotal} participants',
                style: TextStyle(color: AUFTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AUFTheme.textSecondary,
        ),
        onTap: () {
          // Navigation vers la page détaillée de la formation
        },
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activité récente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AUFTheme.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: AUFTheme.primary),
                onPressed: _loadRecentActivities,
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AUFTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child:
              _recentActivities.isEmpty
                  ? Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: AUFTheme.textSecondary.withOpacity(0.5),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Aucune activité récente',
                          style: TextStyle(
                            color: AUFTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _recentActivities.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      final activity = _recentActivities[index];
                      return _buildActivityItem(
                        activity['title'] ?? '',
                        activity['description'] ?? '',
                        _getActivityIcon(activity['type'] ?? ''),
                        activity['created_at'] is DateTime
                            ? activity['created_at']
                            : DateTime.parse(activity['created_at']),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'formation':
        return Icons.school_rounded;
      case 'inscription':
        return Icons.person_add_rounded;
      case 'presence':
        return Icons.check_circle_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'formation':
        return AUFTheme.accent1;
      case 'inscription':
        return AUFTheme.accent2;
      case 'presence':
        return AUFTheme.accent3;
      default:
        return AUFTheme.primary;
    }
  }

  Widget _buildActivityItem(
    String title,
    String description,
    IconData icon,
    DateTime time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActivityColor(title).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _getActivityColor(title), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AUFTheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AUFTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeAgo(time),
                  style: TextStyle(
                    fontSize: 12,
                    color: AUFTheme.textSecondary.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} ${difference.inDays == 1 ? 'jour' : 'jours'}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} ${difference.inHours == 1 ? 'heure' : 'heures'}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'À l\'instant';
    }
  }
}
