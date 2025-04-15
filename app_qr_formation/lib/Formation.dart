import 'package:flutter/material.dart';
import 'add_formation_page.dart';
import 'models/formation_model.dart';
import 'services/formation_service.dart';

class FormationsPage extends StatefulWidget {
  @override
  _FormationsPageState createState() => _FormationsPageState();
}

class _FormationsPageState extends State<FormationsPage> {
  final FormationService _formationService = FormationService();
  List<Formation> _formations = [];
  bool _isLoading = true;
  String? _error;

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

  Widget _buildFormationCard(Formation formation) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 12),
            Text(
              formation.titre,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              formation.description,
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${_formatDate(formation.dateDebut)}',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    Text(
                      'Lieu: ${formation.lieu}',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Places: ${formation.placesReservees}/${formation.placesTotal}',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    _buildStatusChip(formation.statut),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String statut) {
    Color backgroundColor;
    String label;

    switch (statut) {
      case 'a_venir':
        backgroundColor = Colors.blue;
        label = 'À venir';
        break;
      case 'en_cours':
        backgroundColor = Colors.green;
        label = 'En cours';
        break;
      case 'terminee':
        backgroundColor = Colors.grey;
        label = 'Terminée';
        break;
      default:
        backgroundColor = Colors.grey;
        label = 'Inconnu';
    }

    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Formations', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Implémenter le filtrage par statut ici
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: _formations.length,
                itemBuilder:
                    (context, index) => _buildFormationCard(_formations[index]),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFormationPage()),
          ).then((_) {
            // Recharger les formations après l'ajout
            _loadFormations();
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
