import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'formation_detail_page.dart';
import 'services/formation_service.dart';
import 'models/formation_model.dart';
import 'seances_page.dart';

class FormateurHomePage extends StatefulWidget {
  const FormateurHomePage({super.key});

  @override
  State<FormateurHomePage> createState() => _FormateurHomePageState();
}

class _FormateurHomePageState extends State<FormateurHomePage> {
  int? formateurId;
  List<Formation> formations = [];

  @override
  void initState() {
    super.initState();
    _loadFormations();
  }

  Future<void> _loadFormations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    formateurId = prefs.getInt('formateur_id');
    print('formateurId: $formateurId');
    if (formateurId != null) {
      formations = await FormationService().getFormationsByFormateur(
        formateurId!,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes Formations')),
      body:
          formations.isEmpty
              ? Center(child: Text('Aucune formation associée.'))
              : ListView.builder(
                itemCount: formations.length,
                itemBuilder: (context, index) {
                  final formation = formations[index];
                  return Card(
                    child: ListTile(
                      title: Text(formation.titre),
                      subtitle: Text(
                        'Du ${formation.dateDebut} au ${formation.dateFin}',
                      ),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FormationDetailPage(
                                  formationId: formation.id,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
