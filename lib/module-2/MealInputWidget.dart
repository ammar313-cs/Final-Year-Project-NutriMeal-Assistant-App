// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, library_private_types_in_public_api, use_key_in_widget_constructors, avoid_print, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:nutrimeal/gamification/M2game.dart';
import 'package:nutrimeal/gamification/gamififcation.dart';
import 'package:nutrimeal/module-2/gptresponseM2.dart';
import 'package:nutrimeal/module-2/ocr_meal_screen.dart'; // Assuming this file contains the function getGPTResponseFromUserInputM2

int? globalMealval;

String? username_global;

Nutripoints nutripoints1 = Nutripoints(
  username: username_global,
);

class MealInputWidget extends StatefulWidget {
  @override
  _MealInputWidgetState createState() => _MealInputWidgetState();
}

class _MealInputWidgetState extends State<MealInputWidget> {
  TextEditingController totalMealsController = TextEditingController();
  TextEditingController totalCaloriesController = TextEditingController();
  String? selectedMealType;
  bool isLoading = false;

  List<Map<String, dynamic>> mealsList = [];

  bool isInputValid() {
    return totalMealsController.text.isNotEmpty &&
        totalCaloriesController.text.isNotEmpty &&
        selectedMealType != null &&
        apiStateCheck == true &&
        clasifyapistateCheck == true &&
        cleanStateapiCheck == true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: totalMealsController,
          keyboardType: TextInputType.number,
          maxLength: 1,
          onChanged: (value) {
            int inputValue = int.tryParse(value) ?? 0;
            globalMealval = inputValue;
            if (inputValue > 4) {
              totalMealsController.text = '4';
            }
          },
          decoration: InputDecoration(
            labelText: 'Total Meals per Day',
            labelStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 16.0),
        TextField(
          controller: totalCaloriesController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: 'Total Calories per Day',
            labelStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 16.0),
        DropdownButton<String>(
          value: selectedMealType,
          onChanged: (value) {
            setState(() {
              selectedMealType = value!;
            });
          },
          style: TextStyle(color: Colors.black),
          dropdownColor: Colors.black,
          items: [
            DropdownMenuItem(
              value: 'continental',
              child: Row(
                children: [
                  Icon(Icons.fastfood),
                  SizedBox(width: 8.0),
                  Text(
                    'Continental',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'asian',
              child: Row(
                children: [
                  Icon(Icons.fastfood),
                  SizedBox(width: 8.0),
                  Text(
                    'Asian',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'indian',
              child: Row(
                children: [
                  Icon(Icons.fastfood),
                  SizedBox(width: 8.0),
                  Text(
                    'Indian',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          hint: Text(
            'Select Meal Type',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 16.0),
        Container(
          height: 50.0,
          width: 30.0,
          child: ElevatedButton(
            onPressed: isInputValid() && !isLoading
                ? () {
                    setState(() {
                      isLoading = true;
                    });

                    mealsList = [
                      {
                        'totalMeals': totalMealsController.text,
                        'totalCalories': totalCaloriesController.text,
                        'mealType': selectedMealType,
                      }
                    ];

                    getGPTResponseFromUserInputM2(context, mealsList)
                        .then((response) {
                      setState(() {
                        isLoading = false;
                      });
                    }).catchError((error) {
                      print("Error: $error");
                      setState(() {
                        isLoading = false;
                      });
                    });

                    M2gamepopups m2GamePopups = M2gamepopups(
                      nutripoints1,
                      previousStars1: nutripoints1.m2star,
                    );
                    m2GamePopups.nutripoints1.pointsCosumeM2();

                    print(
                        "updates of m2scores:${m2GamePopups.nutripoints1.pointsM2}\n");
                    print(
                        "updates of stars m2:${m2GamePopups.nutripoints1.m2star}\n");
                    print(
                        "updates of total scores:${m2GamePopups.nutripoints1.totalPoints}\n");

                    m2GamePopups.showM2GamePopup(context);
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Please fill in all the required fields.'),
                        backgroundColor: Colors.black,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    30.0,
                  ),
                ),
              ),
              side: MaterialStateProperty.all<BorderSide>(
                BorderSide.none,
              ),
              backgroundColor: MaterialStateProperty.all<Color?>(
                Colors.black,
              ),
              elevation: MaterialStateProperty.all<double>(
                10.0,
              ),
            ),
            child: isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text(
                    'Generate',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
