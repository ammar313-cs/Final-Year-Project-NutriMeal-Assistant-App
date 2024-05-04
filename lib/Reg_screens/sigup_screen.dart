// ignore_for_file: unused_field, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutrimeal/Reg_screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  SignupScreenState createState() => SignupScreenState();
}

// ignore: use_key_in_widget_constructors
class SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool _isFirebaseAuthenticating = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ConfirmPasswordController =
      TextEditingController();

  final Color primaryColor = Colors.purple;
  final Color secondaryColor = Colors.redAccent;
  final Color buttonColor = Colors.black;
  final Color textColor = Colors.white;
  final Color dividerColor = Colors.white;

  Future<void> _signUpWithEmailAndPassword(
    String email,
    String password,
    String username,
    String confirmPassword,
    BuildContext context,
  ) async {
    bool isUsernameAvailable = false;

    try {
      // Check email format
      if (!isValidEmail(email)) {
        _showErrorDialog(context, "Invalid email format");
        return;
      }

      // Check username availability
      isUsernameAvailable = await _isUsernameAvailable(username);
      if (!isUsernameAvailable) {
        _showErrorDialog(context, "Username is taken");
        return;
      }

      // Check password length
      if (password.length < 6) {
        _showErrorDialog(
            context, "Password must be at least 6 characters long");
        return;
      }

      // Check password confirmation
      if (password != confirmPassword) {
        _showErrorDialog(context, "Passwords do not match");
        return;
      }

      final UserCredential authResult =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = authResult.user;

      if (user != null) {
        // Save user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'username': username,
          'isVerified': false, // Assume the user is not initially verified
        });

        // Send email verification
        await user.sendEmailVerification();

        // Show success dialog
        _showSuccessDialog(
            context, "Sign-up successful. Check your email for verification.");
      }
    } catch (e) {
      print("Error during email/password signup: $e");
      _showErrorDialog(context, "Sign-up failed");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text("Error"),
          content: Text(message),
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

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text("Success"),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginScreen(),
                  ),
                );
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

// Function to validate email format
  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegExp.hasMatch(email);
  }

  //Email avalibilty

  Future<bool> _isEmailAvailable(String email) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users') // Replace with your users collection name
          .where('email', isEqualTo: email)
          .get();

      print("Query result: ${querySnapshot.docs.isEmpty}");

      // If the query returns any documents, the email is already in use
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print("Error checking email availability: $e");
      return false;
    }
  }

// Function to check username availability (you may need to implement this)
  Future<bool> _isUsernameAvailable(String username) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users') // Replace with the name of your users collection
          .where('username', isEqualTo: username)
          .get();

      // If the query returns any documents, the username is already taken
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      // Handle any errors that occur during the query (e.g., network issues)
      print("Error checking username availability: $e");
      return false; // Return false to indicate an error or that the username is not available
    }
  }

  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn(
        clientId:
            '277899685082-nn3e4mfo8h6gfndu9ji2h78s32miic7q.apps.googleusercontent.com',
      ).signIn();

      if (googleSignInAccount != null) {
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
          // Handle successful sign-up, you can navigate to another screen or perform other actions.
          print("Google Sign-up successful: ${user.displayName}");
        }
      }
    } catch (e) {
      // Handle sign-up errors here (e.g., display an error message to the user)
      print("Google Sign-up error: $e");
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    'assets/icons/NutriLogo.png',
                    width: 250.0,
                    height: 250.0,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: buttonColor),
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email, color: buttonColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: buttonColor),
                        hintText: 'Enter your username',
                        prefixIcon: Icon(Icons.person, color: buttonColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: buttonColor),
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock, color: buttonColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      controller: ConfirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: buttonColor),
                        hintText: 'Confirm your password',
                        prefixIcon: Icon(Icons.lock, color: buttonColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 60.0,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color?>(
                        Colors.black,
                      ),
                      elevation: MaterialStateProperty.all<double>(10.0),
                    ),
                    onPressed: _isFirebaseAuthenticating
                        ? null // Disable the button when authentication is in progress
                        : () async {
                            // Set the authentication state to true to show the waiting widget
                            setState(() {
                              _isFirebaseAuthenticating = true;
                            });

                            // Perform Firebase signup
                            await _signUpWithEmailAndPassword(
                              emailController.text,
                              passwordController.text,
                              usernameController.text,
                              ConfirmPasswordController.text,
                              context,
                            );

                            // Reset the authentication state after signup is complete
                            setState(() {
                              _isFirebaseAuthenticating = false;
                            });
                          },
                    child: _isFirebaseAuthenticating
                        ? CircularProgressIndicator() // Show a waiting indicator while authenticating
                        : const Text(
                            'Signup',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ), // Show the button text when not authenticating
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
                const SizedBox(height: 20),
                Container(
                  height: 50.0,
                  width: 210.0,
                  child: InkWell(
                    onTap: _signUpWithGoogle,
                    child: Image.asset(
                      "assets/icons/google.png",
                      width: 24.0,
                      height: 24.0,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  height: 40.0, // Set the desired height
                  // width: 20.0, // Set a constant small width
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30.0), // Adjust the radius for the desired roundness
                        ),
                      ),
                      side: MaterialStateProperty.all<BorderSide>(
                        BorderSide.none, // Remove the border side
                      ),
                      backgroundColor: MaterialStateProperty.all<Color?>(
                          Colors.black), // Set the background to black
                      elevation:
                          MaterialStateProperty.all<double>(10.0), // Add shadow
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Back',
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
        ),
      ),
    );
  }
}
