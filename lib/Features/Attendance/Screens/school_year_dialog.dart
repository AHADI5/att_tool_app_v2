import 'package:flutter/material.dart';

class SchoolYearDialog extends StatefulWidget {
  final Function(int, int) onSave;

  SchoolYearDialog({required this.onSave});

  @override
  _SchoolYearDialogState createState() => _SchoolYearDialogState();
}

class _SchoolYearDialogState extends State<SchoolYearDialog> {
  final _formKey = GlobalKey<FormState>();
  int? startYear;
  int? endYear;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter une nouvelle année scolaire'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Année de début'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'année de début';
                }
                return null;
              },
              onSaved: (value) {
                startYear = int.tryParse(value!);
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Année de fin'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'année de fin';
                }
                return null;
              },
              onSaved: (value) {
                endYear = int.tryParse(value!);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              if (startYear != null && endYear != null) {
                widget.onSave(startYear!, endYear!);
                Navigator.of(context).pop();
              }
            }
          },
          child: Text('Enregistrer'),
        ),
      ],
    );
  }
}
