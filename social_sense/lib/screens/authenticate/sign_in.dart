// import 'package:flutter/material.dart';
// import 'package:social_sense/services/auth.dart';
// import 'package:social_sense/shared/constants.dart';
// import 'package:social_sense/shared/loading.dart';

// class SignIn extends StatefulWidget {
//   final Function toggleView; // toggleView is a required parameter
//   SignIn({required this.toggleView}); // Make sure this is marked as required

//   @override
//   State<SignIn> createState() => _SignInState();
// }

// class _SignInState extends State<SignIn> {
//   final AuthService _auth = AuthService();
//   final _formKey = GlobalKey<FormState>();
//   bool loading = false;

//   // text field state
//   String email = '';
//   String password = '';
//   String error = '';

//   @override
//   Widget build(BuildContext context) {
//     return loading
//         ? Loading()
//         : Scaffold(
//             backgroundColor: Colors.brown[100],
//             appBar: AppBar(
//               backgroundColor: Colors.brown[400],
//               elevation: 0.0,
//               title: Text('Sign in to Social Sense'),
//               actions: <Widget>[
//                 TextButton.icon(
//                   icon: Icon(Icons.person),
//                   label: Text('Register'),
//                   onPressed: () {
//                     widget.toggleView();
//                   },
//                 )
//               ],
//             ),
//             body: Container(
//                 padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(children: <Widget>[
//                     SizedBox(height: 20.0),
//                     TextFormField(
//                       decoration:
//                           textInputDecoration.copyWith(hintText: 'Email'),
//                       validator: (val) =>
//                           (val?.isEmpty ?? true) ? 'Enter an email' : null,
//                       onChanged: (val) {
//                         setState(() => email = val);
//                       },
//                     ),
//                     SizedBox(height: 20.0),
//                     TextFormField(
//                       decoration:
//                           textInputDecoration.copyWith(hintText: 'Password'),
//                       validator: (val) => (val?.length ?? 0) < 6
//                           ? 'Enter a password that is 6 characters long'
//                           : null,
//                       onChanged: (val) {
//                         setState(() => password = val);
//                       },
//                     ),
//                     SizedBox(height: 20.0),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.pink[400], // Background color
//                       ),
//                       child: Text(
//                         'Sign in',
//                         style: TextStyle(color: Colors.white), // Text color
//                       ),
//                       onPressed: () async {
//                         if (_formKey.currentState?.validate() ?? false) {
//                           setState(() => loading = true);
//                           dynamic result = await _auth
//                               .signInWithEmailAndPassword(email, password);
//                           if (result == null) {
//                             setState(() {
//                               error =
//                                   'could not sign in with those credentials';
//                               loading = false;
//                             });
//                           }
//                         }
//                       },
//                     ),
//                     SizedBox(height: 12.0),
//                     Text(
//                       error,
//                       style: TextStyle(color: Colors.red, fontSize: 14.0),
//                     )
//                   ]),
//                 )),
//           );
//   }
// }

import 'package:flutter/material.dart';
import 'package:social_sense/services/auth.dart';
import 'package:social_sense/shared/constants.dart';
import 'package:social_sense/shared/loading.dart';


class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
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
            backgroundColor: Colors.brown[100],
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
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
            body: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Email'),
                      validator: (val) =>
                          (val?.isEmpty ?? true) ? 'Enter an email' : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Password'),
                      validator: (val) => (val?.length ?? 0) < 6
                          ? 'Enter a password that is 6 characters long'
                          : null,
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                      ),
                      child: Text(
                        'Sign in',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() => loading = true);
                          dynamic result = await _auth
                              .signInWithEmailAndPassword(email, password);
                          if (result == null) {
                            setState(() {
                              error =
                                  'Could not sign in with those credentials';
                              loading = false;
                            });
                          }
                        }
                      },
                    ),
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
                    )
                  ]),
                )),
          );
  }
}
