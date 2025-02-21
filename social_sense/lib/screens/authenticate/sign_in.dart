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

  // Function to handle password reset
  void _resetPassword() async {
    if (email.isEmpty) {
      setState(() {
        error = 'Enter your email to reset password';
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to your email')),
      );
    } catch (e) {
      setState(() {
        error = 'Error sending password reset email';
      });
    }
  }

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
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                      constraints: BoxConstraints(maxWidth: 400), // Adjust the maxWidth to make the box smaller
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo in the middle
                          Image.asset(
                            'assets/logo_bear.png', // Path to the logo image
                            height: 300.0, // Adjust the height as needed
                          ),
                          SizedBox(height: 20.0),
                          // Title
                          Text(
                            'Login',
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
                                    backgroundColor: const Color.fromARGB(255, 103, 27, 131), // Background color
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
                                TextButton(
                                  onPressed: _resetPassword,
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: Colors.blue),
                                  ),
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
                                    Text("Need an account? "),
                                    GestureDetector(
                                      onTap: () {
                                        widget.toggleView();
                                      },
                                      child: Text(
                                        "Register",
                                        style: TextStyle(
                                          color: const Color.fromARGB(255, 58, 131, 190),
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



