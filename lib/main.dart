// ignore_for_file: unused_import, prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nutrimeal/LoadingScreen.dart';
import 'package:nutrimeal/firebase_options.dart';
import 'package:nutrimeal/module-1/prompt_screen.dart';
import 'Reg_screens/login_screen.dart';
import 'package:dcdg/dcdg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

String? username;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add any other asynchronous initialization code here
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    // Add other async operations if needed
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriMeal',
      theme: ThemeData(
        primarySwatch: Colors.red,
        //scaffoldBackgroundColor: Colors.yellow[800] ,
      ),
      // home: PromptScreen(), // change back to authentication wrapper later in the production phase now
      home: LoadingScreen(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Check the connection state of Firebase initialization
      future: Future.wait([
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        // Add other async operations if needed
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If all initializations are complete, show the login screen
          return LoginScreen();
        } else if (snapshot.hasError) {
          // If there's an error during initialization, handle it here
          return Scaffold(
            body: Center(
              child: Text('Error initializing: ${snapshot.error}'),
            ),
          );
        } else {
          // Otherwise, show a loading screen
          return LoadingScreen();
        }
      },
    );
  }
}
