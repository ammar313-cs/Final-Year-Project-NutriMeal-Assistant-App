// ignore_for_file: prefer_const_constructors, must_be_immutable, non_constant_identifier_names, use_key_in_widget_constructors, file_names, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrimeal/gamification/gamififcation.dart';

class M1gamepopups extends StatelessWidget {
  final Nutripoints nutripoints;

  User? user;
  String? username_global;
  late final int previousStars;

  M1gamepopups(this.nutripoints, {required this.previousStars}) {
    user = FirebaseAuth.instance.currentUser;
    username_global = user?.displayName;
  }

  void showM1GamePopup(BuildContext context) {
    int stars =
        nutripoints.alotstars(nutripoints.pointsM1, nutripoints.pointsM2);
    print('Star count dry running:$stars');

    String title = 'Congratulations!';
    String content =
        'You have earned $stars RecipieStars by generating a cool recipe!Yohoo!';
    Widget gifWidget = Image.asset(
      'assets/gifs/giphy1.gif',
      repeat: ImageRepeat.noRepeat,
      cacheWidth: 20,
      cacheHeight: 20,
    );

    if (stars == 0) {
      title = 'No Stars Earned Yet?!';
      content =
          'Sad to see you have no RecipieStars yet, keep generating delicious recipies to earn more RecipieStars!';
      gifWidget = Image.asset(
        'assets/gifs/giphy.gif',
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
    if (stars != previousStars) {
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
      previousStars = stars;
    }
  }

  @override
  Widget build(BuildContext context) {
    //nothing happening here keep in mind this is just working snippet for stateless class
    return Container();
  }
}
