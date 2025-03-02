import 'package:flutter/material.dart';
import 'package:social_sense/services/database.dart';
import 'package:social_sense/screens/home/home.dart';


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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/topOrange_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                title: Text('Change Information'),
                backgroundColor: const Color.fromARGB(21, 149, 71, 42),
              ),
              Expanded(
                child: Padding(
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Home(uid: widget.uid)), // Use Home instead of HomeScreen
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
