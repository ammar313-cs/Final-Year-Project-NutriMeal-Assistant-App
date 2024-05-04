// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, must_be_immutable, prefer_final_fields, prefer_const_literals_to_create_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_bar.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _newUsernameController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();

  // Function to show a dialog with a message
  Future<void> _showDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Result'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChangeUsernameField() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _newUsernameController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'New Username',
                    labelStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangePasswordField() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.lock,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeUsername() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'username': _newUsernameController.text,
        });
        _showDialog('Username changed successfully');
      }
    } catch (e) {
      print('Error changing username: $e');
      _showDialog('Error changing username: $e');
    }
  }

  Future<void> _changePassword() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(_newPasswordController.text);
        _showDialog('Password changed successfully');
      }
    } catch (e) {
      print('Error changing password: $e');
      _showDialog('Error changing password: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBarWithDrawer(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.4, 0.7],
            tileMode: TileMode.repeated,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/icons/NutriLogo.png',
                width: 200.0,
                height: 200.0,
              ),
              SizedBox(height: 50.0),
              _buildChangeUsernameField(),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _changeUsername();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.black), // Set button color
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // Set text color
                ),
                child: Text('Change Username'),
              ),
              SizedBox(
                height: 20,
              ),
              _buildChangePasswordField(),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _changePassword();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.black), // Set button color
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // Set text color
                ),
                child: Text('Change Password'),
              ),
              SizedBox(height: 300.0),
            ],
          ),
        ),
      ),
    );
  }
}
