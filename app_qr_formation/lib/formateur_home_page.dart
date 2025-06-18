// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/formation_service.dart';
import 'models/formation_model.dart';
import 'formateur_profile_page.dart';
import 'formateur_formations_page.dart';

class AUFColors {
  static const Color primary = Color(0xFFB2122B);
  static const Color secondary = Color(0xFF333333);
  static const Color accent1 = Color(0xFF8BC34A);
  static const Color accent2 = Color(0xFF673AB7);
  static const Color accent3 = Color(0xFFFFD600);
  static const Color accent4 = Color(0xFF03A9F4);
  static const Color background = Color(0xFFF5F5F5);
}

class FormateurHomePage extends StatefulWidget {
  const FormateurHomePage({super.key});

  @override
  State<FormateurHomePage> createState() => _FormateurHomePageState();
}

class _FormateurHomePageState extends State<FormateurHomePage> {
  int _selectedIndex = 0;
  int? formateurId;
  String prenom = '';
  List<Formation> formations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormateurData();
  }

  Future<void> _loadFormateurData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    formateurId = prefs.getInt('formateur_id');
    prenom = prefs.getString('prenom') ?? '';
    if (formateurId != null) {
      formations = await FormationService().getFormationsByFormateur(
        formateurId!,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Ajoute cette méthode pour afficher les notifications
  void _showNotifications(List<Map<String, String>> notifications) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child:
              notifications.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Aucune notification",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final notif = notifications[i];
                      return ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: AUFColors.accent4,
                        ),
                        title: Text(notif["message"] ?? ""),
                        subtitle: Text("Le ${notif["date"]}"),
                      );
                    },
                  ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nombre total de participants sur toutes les formations
    int nbParticipants = formations.fold(
      0,
      (sum, f) => sum + (f.nombreParticipantsAcceptes),
    );

    // Prochaines séances (sessions à venir, triées par date)
    List<Map<String, dynamic>> prochainesSeances = [];
    for (var formation in formations) {
      if (formation.dateDebut.isAfter(DateTime.now())) {
        prochainesSeances.add({
          "titre": formation.titre,
          "date":
              "${formation.dateDebut.day.toString().padLeft(2, '0')}/${formation.dateDebut.month.toString().padLeft(2, '0')}/${formation.dateDebut.year}",
          "lieu": formation.lieu,
        });
      }
    }
    prochainesSeances.sort((a, b) => a["date"].compareTo(b["date"]));
    prochainesSeances = prochainesSeances.take(3).toList();

    // Notifications dynamiques (doit être calculé ici pour l'AppBar)
    Map<String, dynamic>? prochaineFormation =
        prochainesSeances.isNotEmpty ? prochainesSeances.first : null;
    final List<Map<String, String>> notifications = [
      if (prochaineFormation != null)
        {
          "message":
              "N'oubliez pas la formation '${prochaineFormation["titre"]}' le ${prochaineFormation["date"]} à ${prochaineFormation["lieu"]}.",
          "date": prochaineFormation["date"],
        },
      {
        "message": "Votre profil est à jour.",
        "date":
            "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
      },
    ];

    final List<Widget> pages = [
      _AccueilWidget(
        prenom: prenom,
        formations: formations,
        prochainesSeances: prochainesSeances,
        nbParticipants: nbParticipants,
        isLoading: isLoading,
        notifications: notifications, // <-- Ajoute ce paramètre
      ),
      FormateurFormationsPage(formations: formations, isLoading: isLoading),
      const FormateurProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AUFColors.background,
      appBar: AppBar(
        backgroundColor: AUFColors.primary,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/AUF-Nouveau-Logo.png', height: 36),
            const SizedBox(width: 12),
            Text(
              _selectedIndex == 0
                  ? 'Accueil Formateur'
                  : _selectedIndex == 1
                  ? 'Formations'
                  : 'Profil',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
            tooltip: 'Notifications',
            onPressed: () => _showNotifications(notifications),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AUFColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: 'Formations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// Widget d'accueil séparé pour garder la logique claire
class _AccueilWidget extends StatelessWidget {
  final String prenom;
  final List<Formation> formations;
  final List<Map<String, dynamic>> prochainesSeances;
  final int nbParticipants;
  final bool isLoading;
  final List<Map<String, String>> notifications; // <-- Ajoute ce paramètre

  const _AccueilWidget({
    required this.prenom,
    required this.formations,
    required this.prochainesSeances,
    required this.nbParticipants,
    required this.isLoading,
    required this.notifications, // <-- Ajoute ce paramètre
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AUFColors.primary),
      );
    }

    // On prend la formation la plus proche (prochaine formation)
    Map<String, dynamic>? prochaineFormation =
        prochainesSeances.isNotEmpty ? prochainesSeances.first : null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AUFColors.primary, AUFColors.accent4],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AUFColors.primary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AUFColors.primary, size: 36),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bonjour $prenom 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Voici un résumé de votre activité AUF.",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Statistiques modernes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statCard(
              "Formations",
              formations.length,
              AUFColors.accent1,
              Icons.school,
            ),
            _statCard(
              "Participants",
              nbParticipants,
              AUFColors.accent3,
              Icons.group,
            ),
            _statCard(
              "À venir",
              prochaineFormation != null ? 1 : 0,
              AUFColors.accent2,
              Icons.event_note,
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Prochaine formation
        Text(
          "Prochaine formation",
          style: TextStyle(
            color: AUFColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        if (prochaineFormation == null)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.event_busy, color: AUFColors.primary),
                  const SizedBox(width: 16),
                  const Text(
                    "Aucune formation à venir.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          _nextFormationCard(prochaineFormation),

        // Supprime la section "Notifications" ici, car elles sont maintenant dans le BottomSheet
      ],
    );
  }

  Widget _statCard(String label, int value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                "$value",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AUFColors.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nextFormationCard(Map<String, dynamic> formation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: Icon(Icons.event, color: AUFColors.primary),
        title: Text(formation["titre"] ?? ""),
        subtitle: Text("${formation["date"]} - ${formation["lieu"]}"),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AUFColors.secondary,
        ),
        onTap: () {
          // Naviguer vers le détail de la formation si besoin
        },
      ),
    );
  }
}
