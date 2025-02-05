import 'package:flutter/material.dart';
import 'package:social_sense/services/auth.dart';
import 'package:social_sense/shared/constants.dart';
import 'package:social_sense/shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleView; // toggleView is a required parameter
  SignIn({required this.toggleView}); // Make sure this is marked as required

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: Stack(
              children: [
                // Background image
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/bottomPurple_background.png'), // Path to your image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Foreground content
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                    constraints: BoxConstraints(maxWidth: 400), // Adjust the maxWidth to make the box smaller
                    color: Colors.green.withOpacity(0), // Set the color with opacity
                    child: Column(
                      children: [
                        AppBar(
                          backgroundColor: const Color.fromARGB(255, 124, 206, 158).withOpacity(0), // Set the AppBar color with opacity
                          elevation: 0.0,
                          title: Text('Sign in to Social Sense'),
                          actions: <Widget>[
                            TextButton.icon(
                              icon: Icon(Icons.person),
                              label: Text('Register'),
                              onPressed: () {
                                widget.toggleView();
                              },
                            )
                          ],
                        ),
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 20.0),
                                TextFormField(
                                  decoration: textInputDecoration.copyWith(hintText: 'Email'),
                                  validator: (val) => (val?.isEmpty ?? true) ? 'Enter an email' : null,
                                  onChanged: (val) {
                                    setState(() => email = val);
                                  },
                                ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  decoration: textInputDecoration.copyWith(hintText: 'Password'),
                                  validator: (val) => (val?.length ?? 0) < 6 ? 'Enter a password that is 6 characters long' : null,
                                  onChanged: (val) {
                                    setState(() => password = val);
                                  },
                                ),
                                SizedBox(height: 20.0),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pink[400], // Background color
                                  ),
                                  child: Text(
                                    'Sign in',
                                    style: TextStyle(color: Colors.white), // Text color
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      setState(() => loading = true);
                                      dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                                      if (result == null) {
                                        setState(() {
                                          error = 'could not sign in with those credentials';
                                          loading = false;
                                        });
                                      }
                                    }
                                  },
                                ),
                                SizedBox(height: 12.0),
                                Text(
                                  error,
                                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
