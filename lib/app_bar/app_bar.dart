// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrimeal/app_bar/settings.dart';
import 'package:nutrimeal/gamification/gamififcation.dart';
import 'package:nutrimeal/module-1/prompt_screen.dart';
import 'package:nutrimeal/module-2/MealInputWidget.dart';

import '../Reg_screens/login_screen.dart';
import '../module-1/prompt_screen.dart' as mod1;
import '../module-2/ocr_meal_screen.dart' as module2;

class CustomAppBarWithDrawer extends StatelessWidget
    implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBarWithDrawer({
    Key? key,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          size: 30.0,
        ),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
      backgroundColor: Colors.redAccent,
      elevation: 0,
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.0),
          child: Row(
            children: [
              Container(
                //  margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Image.asset(
                  'assets/icons/NutriLogo.png',
                  width: 100.0,
                  height: 100.0,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 55),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                Icons.monetization_on_rounded,
                color: Colors.yellow,
              ),
              SizedBox(width: 8),
              Text(
                'TP:${nutripoints.totalPoints + nutripoints1.totalPoints}', // Display the user's score here
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12),
              Icon(
                Icons.star,
                color: Colors.yellow,
              ),
              SizedBox(width: 8),
              Text(
                'TC:${nutripoints.totalStars + nutripoints1.m2star}', // Display the user's score here
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width * 0.1,
        child: Column(
          children: [
            SizedBox(height: 25),
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Image.asset(
                'assets/icons/NutriLogo1.png',
                width: 100.0,
                height: 100.0,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.food_bank,
                color: Colors.white,
              ),
              title: Text(
                'Recipe Generator ',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => mod1.PromptScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.set_meal,
                color: Colors.white,
              ),
              title: Text(
                'Meal Plan Generator ',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => module2.OCRScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              title: Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                } catch (e) {
                  print('Error signing out: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
