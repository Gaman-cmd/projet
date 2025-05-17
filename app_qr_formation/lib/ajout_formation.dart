import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importez le package intl

class AddTrainingPage extends StatefulWidget {
  @override
  _AddTrainingPageState createState() => _AddTrainingPageState();
}

class _AddTrainingPageState extends State<AddTrainingPage> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _location;
  String? _instructor;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une formation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
                onSaved: (value) => _title = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Date de début'),
                      controller: TextEditingController(
                        text: _startDate != null
                            ? DateFormat.yMd().format(_startDate!)
                            : '',
                      ),
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, true),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Date de fin'),
                      controller: TextEditingController(
                        text: _endDate != null ? DateFormat.yMd().format(_endDate!) : '',
                      ),
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, false),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Lieu'),
                onSaved: (value) => _location = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Formateur'),
                onSaved: (value) => _instructor = value,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Ajoutez ici la logique pour enregistrer la formation
                      print('Titre: $_title');
                      print('Description: $_description');
                      print('Date de début: $_startDate');
                      print('Date de fin: $_endDate');
                      print('Lieu: $_location');
                      print('Formateur: $_instructor');
                    }
                  },
                  child: Text('Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}