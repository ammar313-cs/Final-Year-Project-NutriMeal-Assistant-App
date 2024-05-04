// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unused_import

import 'package:flutter/material.dart';
import 'package:nutrimeal/main.dart';

import 'package:nutrimeal/module-1/prompt_screen.dart';
import 'Reg_screens/login_screen.dart';

import 'package:path_provider/path_provider.dart';

import 'package:shimmer/shimmer.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(Duration(seconds: 3)); // Adjust duration as needed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthenticationWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.purple,
          width: 3.0,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AnimatedContainer(
            duration: Duration(seconds: 3),
            curve: Curves.easeOut,
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/NutriLogo1.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
