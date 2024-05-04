// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, avoid_print, sized_box_for_whitespace, unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrimeal/Reg_screens/sigup_screen.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutrimeal/module-1/prompt_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

User? user;
String? username_global;

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode(); // Add FocusNode

  bool _isLoading = false;

  Future<void> _showErrorDialog(
      //error dailouge for the verification
      BuildContext context,
      String errorMessage) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text('Sign-In Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      user = userCredential.user;

      if (user != null) {
        await user!.reload();
        user = _auth.currentUser;
        print("user:$user");

        if (user != null && user!.emailVerified) {
          // Navigate to the desired screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PromptScreen(),
            ),
          );
        } else {
          // User's email is not verified, show an error message
          _showErrorDialog(
              context, 'Email not verified. Please check your email.');
          // You can also provide an option to resend the verification email here
        }
      }
    } catch (e) {
      // Handle sign-in errors here
      String errorMessage = 'Sign-in failed. Please check your credentials.';
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          errorMessage = 'User not found. Please check your email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password. Please try again.';
        }
      }

      // Show the error message in a dialog box
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text('Sign-In Error'),
            content: Text(errorMessage),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                ),
                child: Text("OK"),
              ),
            ],
          );
        },
      );

      print("Sign-in error: $e");
    } finally {
      // Set _isLoading to false when the login process is complete
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    // Initialize GoogleSignIn with  Client ID
    final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn(
      clientId:
          '277899685082-nn3e4mfo8h6gfndu9ji2h78s32miic7q.apps.googleusercontent.com',
    ).signIn();

    if (googleSignInAccount != null) {
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          // Handle successful sign-in, can navigate to another screen or perform other actions.
          print("Google Sign-in successful: ${user.displayName}");
        }
      } catch (e) {
        // Handle sign-in errors here
        print("Google Sign-in error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.redAccent],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: [0.4, 0.7],
            tileMode: TileMode.repeated,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 70.0,
              horizontal: 70.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    'assets/icons/NutriLogo.png', // Replace with the path to your logo image asset
                    width: 350.0, // Adjust the width as needed
                    height: 350.0, // Adjust the height as needed
                  ),
                ),

                // Email input field
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(30.0), // Rounded corners
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: _emailFocus, // Assign the focus node
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.black),
                            hintText: 'Enter your email',
                            prefixIcon: Icon(Icons.email, color: Colors.black),
                            border: InputBorder.none, // No border
                            fillColor:
                                Colors.transparent, // Colorless background
                            filled: true, // To enable the fill color
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Password input field
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(30.0), // Rounded corners
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock, color: Colors.black),
                        border: InputBorder.none, // No border
                        fillColor: Colors.transparent, // Colorless background
                        filled: true, // To enable the fill color
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 45),

                // Login button
                Container(
                  height: 60.0, // Set the desired height
                  width: 70.0, // Set a constant small width
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Loading indicator (conditionally displayed)
                      if (_isLoading)
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),

                      // Login button text (conditionally displayed)
                      if (!_isLoading)
                        OutlinedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  30.0, // Adjust the radius for the desired roundness
                                ),
                              ),
                            ),
                            side: MaterialStateProperty.all<BorderSide>(
                              BorderSide.none, // Remove the border side
                            ),
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              Colors.black,
                            ), // Set the background to black
                            elevation: MaterialStateProperty.all<double>(
                              10.0, // Add shadow
                            ),
                          ),
                          onPressed: () => _signInWithEmailAndPassword(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical:
                                  20.0, // Adjust the vertical padding for the desired height
                              horizontal:
                                  80.0, // Adjust the horizontal padding for the desired width
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white, // Text color is white
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Or Continue with',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1.0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Google Sign-In button
                Container(
                  height: 50.0,
                  width: 210.0,
                  child: InkWell(
                    onTap:
                        _handleGoogleSignIn, // Use the Google Sign-In function
                    child: Image.asset("assets/icons/google.png",
                        width: 24.0, height: 24.0),
                  ),
                ),

                const SizedBox(height: 20),

                // Sign-up button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Dont Have an account? Signup',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
