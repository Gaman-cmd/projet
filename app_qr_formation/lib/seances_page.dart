/*import 'package:flutter/material.dart';
import 'models/formation_model.dart';
import 'services/session_service.dart';
import 'models/session_model.dart';
import 'presence_page.dart';

class SeancesPage extends StatefulWidget {
  final Formation formation;
  SeancesPage({required this.formation});

  @override
  State<SeancesPage> createState() => _SeancesPageState();
}

class _SeancesPageState extends State<SeancesPage> {
  List<Session> seances = [];

  @override
  void initState() {
    super.initState();
    _loadSeances();
  }

  Future<void> _loadSeances() async {
    seances = await SessionService().getSessionsByFormation(
      widget.formation.id,
    );
    setState(() {});
  }

  void _ajouterSeance() async {
    final _dateController = TextEditingController();
    final _heureController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Ajouter une séance'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Date requise' : null,
                  ),
                  TextFormField(
                    controller: _heureController,
                    decoration: InputDecoration(labelText: 'Heure (HH:MM)'),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Heure requise' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await SessionService().addSession(
                      widget.formation.id,
                      _dateController.text,
                      _heureController.text,
                    );
                    Navigator.pop(context);
                    _loadSeances();
                  }
                },
                child: Text('Ajouter'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Séances')),
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterSeance,
        child: Icon(Icons.add),
        tooltip: 'Ajouter une séance',
      ),
      body:
          seances.isEmpty
              ? Center(child: Text('Aucune séance'))
              : ListView.builder(
                itemCount: seances.length,
                itemBuilder: (context, index) {
                  final seance = seances[index];
                  return ListTile(
                    title: Text('Séance du ${seance.date} à ${seance.heure}'),
                    trailing: Icon(Icons.people),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PresencePage(seance: seance),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
*/
