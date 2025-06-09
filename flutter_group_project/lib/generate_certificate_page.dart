import 'package:flutter/material.dart';

class GenerateCertificatePage extends StatefulWidget {
  @override
  _GenerateCertificatePageState createState() =>
      _GenerateCertificatePageState();
}

class _GenerateCertificatePageState extends State<GenerateCertificatePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '', organization = '', purpose = '';
  DateTime issuedDate = DateTime.now(),
      expiryDate = DateTime.now().add(Duration(days: 365));

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: Call backend API to generate and upload certificate
      print('Certificate Created for $name');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate Certificate')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Recipient Name'),
                onSaved: (val) => name = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Organization'),
                onSaved: (val) => organization = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Purpose'),
                onSaved: (val) => purpose = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Generate Certificate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
