import 'package:flutter/material.dart';
import 'package:social_sense/services/database.dart';

class InformationScreen extends StatefulWidget {
  final String uid;
  InformationScreen({required this.uid});

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Information'),
        backgroundColor: Colors.brown[400],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (val) => val!.isEmpty ? 'Enter your first name' : null,
                onChanged: (val) {
                  setState(() => firstName = val);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (val) => val!.isEmpty ? 'Enter your last name' : null,
                onChanged: (val) {
                  setState(() => lastName = val);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await DatabaseService(uid: widget.uid).updateUserData(firstName, lastName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Information Saved!'))
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
