// ignore_for_file: use_build_context_synchronously, avoid_print, duplicate_import, unused_local_variable, avoid_function_literals_in_foreach_calls, file_names

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:nutrimeal/module-2/MealPlan.dart';
import 'dart:convert';

import 'package:nutrimeal/module-2/ocr_meal_screen.dart';
import 'package:nutrimeal/module-2/MealPlan.dart';

class Meal {
  final String totalMeals;
  final String totalCalories;
  final String mealType;

  Meal({
    required this.totalMeals,
    required this.totalCalories,
    required this.mealType,
  });

  // Named constructor to create Meal instance from a map
  Meal.fromMap(Map<String, dynamic> map)
      : totalMeals = map['totalMeals'],
        totalCalories = map['totalCalories'],
        mealType = map['mealType'];
}

class OpenAIConfig {
  static const String apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String apiKey =
      ''; // actual API key
}

Future<Map<String, dynamic>> fetchGPTResponseM2(
    BuildContext context, List<Map<String, dynamic>> mealsList) async {
  List<Meal> meals = mealsList.map((meal) => Meal.fromMap(meal)).toList();
  String? mealDetails;

  String gptPrompt =
      "You are a Meal Assistant and planner, you will provide meals per day for the user based on the (total number of meals) specified by the user and you will give each each meal its relevant name(Breakfast,Lunch,Dinner and snack if number of meals is 4 only), the type of cuisine, and the total number of calories per day provided, use exact number of claories given by user to distribute it for per day . Only the provided ingredients will be used to create a weekly meal plan for the user.  you will provide dish names and total calories per meal only, adhering strictly to the provided ingredients. No additional grocery items will be included by you only use given items. You will design the meal plan from Monday to Sunday. You will only provide meal names and total calories per meal. You will design a meal plan in accordance with Breakfast Lunch and Dinner, or on the basis of number of meals provided to you by the user. You will only give dish names. You will start with Monday and provide each meal in 4 words maximum, Numerical number of calories in 1 word maximum. Total number of words per day must not exceed 18 words";

  for (var meal in meals) {
    mealDetails =
        'Total meals per day: ${meal.totalMeals}, Total number of calories per day required: ${meal.totalCalories}, Meal type: ${meal.mealType},Only Usable available and all Ingredients: $edibleItems';
    print(mealDetails);
  }

  final response = await http.post(
    Uri.parse(OpenAIConfig.apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo-16k',
      'messages': [
        {
          'role': 'assistant',
          'content': gptPrompt,
        },
        {
          'role': 'user',
          'content': mealDetails,
        },
      ],
      'max_tokens': 3000, // Adjust max tokens as needed
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final a = response.body;
    // print('GPT Response: $a');

    final message = jsonResponse['choices'][0]['message'];

    if (message != null) {
      // Split the message by day names
      final mealsByDay = message['content'].split('\n\n');

      // Create a map to store the structured data
      final Map<String, List<String>> dayWiseData = {};

      // Iterate through each day's meal data
      for (var dayMeals in mealsByDay) {
        // Split each day's meal data into lines
        final lines = dayMeals.split('\n');
        // Extract the day name from the first line
        final dayName = lines.first;
        // Remove the day name from the lines
        final meals = lines.sublist(1);
        // Store the meals for the day in the map
        dayWiseData[dayName] = meals;
      }

      // Print day-wise data
      dayWiseData.forEach((day, meals) {
        print('$day:');
        meals.forEach((meal) {
          print('- $meal');
        });
      });

      // Pass the day-wise structured data to ApiResponsePage
      final Map<String, dynamic> responseMap = {
        'responseBody': response.body,
        'dayWiseData': dayWiseData,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeeklyMealPlanPage(mealPlan: dayWiseData),
        ),
      );
      print('hello:::::d$dayWiseData');
      return dayWiseData;
    } else {
      throw Exception('Message is null in GPT response');
    }
  } else {
    throw Exception('Failed to fetch GPT response');
  }
}

Future<Map<String, dynamic>> getGPTResponseFromUserInputM2(
    BuildContext context, List<Map<String, dynamic>> mealsList) async {
  // Assuming fetchGPTResponseM2 expects a list of meals as input
  final gptResponse = await fetchGPTResponseM2(context, mealsList);
  return gptResponse;
}
