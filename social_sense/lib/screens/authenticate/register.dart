import 'package:flutter/material.dart';
import 'package:social_sense/services/auth.dart';
import 'package:social_sense/shared/constants.dart';
import 'package:social_sense/shared/loading.dart';

class Register extends StatefulWidget {
  final Function toggleView; // toggleView is a required parameter
  Register({required this.toggleView}); // Make sure this is marked as required

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
                // Background image with color filter
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2), // Change this to the desired color
                    BlendMode.darken,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/bottomPurple_background.png'), // Path to your image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Foreground content
                Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                      constraints: BoxConstraints(maxWidth: 400), // Adjust the maxWidth to make the box smaller
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo in the middle
                          Image.asset(
                            'assets/logo_bear.png', // Path to your logo image
                            height: 300.0, // Adjust the height as needed
                          ),
                          SizedBox(height: 20.0),
                          // Title
                          Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 20.0),
                                TextFormField(
                                  decoration: textInputDecoration.copyWith(
                                    hintText: 'Email',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  validator: (val) => (val?.isEmpty ?? true) ? 'Enter an email' : null,
                                  onChanged: (val) {
                                    setState(() => email = val);
                                  },
                                ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  decoration: textInputDecoration.copyWith(
                                    hintText: 'Password',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  obscureText: true,
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
                                    'Register',
                                    style: TextStyle(color: Colors.white), // Text color
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      setState(() => loading = true);
                                      dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                                      if (!mounted) return; // Check if the widget is still mounted
                                      if (result == null) {
                                        setState(() {
                                          error = 'Please supply a valid email';
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
                                ),
                                SizedBox(height: 20.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Already have an account? "),
                                    GestureDetector(
                                      onTap: () {
                                        widget.toggleView();
                                      },
                                      child: Text(
                                        "Sign in",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}





