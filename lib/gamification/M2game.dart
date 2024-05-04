// ignore_for_file: prefer_const_constructors, must_be_immutable, non_constant_identifier_names, use_key_in_widget_constructors, file_names, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrimeal/gamification/gamififcation.dart';

class M2gamepopups extends StatelessWidget {
  final Nutripoints nutripoints1;

  User? user;
  String? username_global;
  late final int previousStars1;

  M2gamepopups(this.nutripoints1, {required this.previousStars1}) {
    user = FirebaseAuth.instance.currentUser;
    username_global = user?.displayName;
  }

  void showM2GamePopup(BuildContext context) {
    int stars1 = nutripoints1.alotstarsM2(nutripoints1.pointsM2);
    print('Star count dry running:$stars1');

    String title = 'Congratulations!';
    String content =
        'You have earned $stars1 MealStars by generating a cool meal plan!Yohooo!';
    Widget gifWidget = Image.asset(
      'assets/gifs/giphy5.gif',
      repeat: ImageRepeat.noRepeat,
      cacheWidth: 20,
      cacheHeight: 20,
    );

    if (stars1 == 0) {
      title = 'No Stars Earned Yet?!';
      content =
          'Sad to see you have no MealStars yet, keep generating healthy meal plans to earn more MealStars!';
      gifWidget = Image.asset(
        'assets/gifs/giphy4.gif',
        repeat: ImageRepeat.noRepeat,
        cacheWidth: 20,
        cacheHeight: 20,
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                gifWidget,
                SizedBox(height: 10),
                Text(content),
              ],
            ),
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
    }

    // Check if the number of stars has changed from the previous value
    if (stars1 != previousStars1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                gifWidget,
                SizedBox(height: 10),
                Text(content),
              ],
            ),
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

      // Update the previous star count
      previousStars1 = stars1;
    }
  }

  @override
  Widget build(BuildContext context) {
    //nothing happening here keep in mind this is just working snippet for stateless class
    return Container();
  }
}
