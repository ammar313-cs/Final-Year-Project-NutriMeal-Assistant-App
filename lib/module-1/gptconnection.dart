// ignore_for_file: unused_element, unnecessary_import, non_constant_identifier_names, avoid_print, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:nutrimeal/Reg_screens/login_screen.dart';
import 'package:nutrimeal/module-1/dalleconnection.dart';
import 'package:firebase_auth/firebase_auth.dart';

dynamic _imageFetchingException;

class OpenAIConfig {
  static const String apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String apiKey =
      ''; // actual API key
}

String generateSharedUUID() {
  final uuid = Uuid();
  return uuid.v4();
}

String sharedUUID = ""; //global var for shared uuid for text-img
String? dishName_img = ''; //gloabl var for image name fo img-db

Future<void> saveResponseToFirestore(
  String userId,
  String sharedUid,
  Map<String, dynamic> response,
) async {
  try {
    final userResponseCollection = FirebaseFirestore.instance
        .collection('user_responses')
        .doc(userId)
        .collection('responses');

    await userResponseCollection.doc(sharedUid).set({
      ...response,
      'timestamp': FieldValue.serverTimestamp(),
      'sharedUid': sharedUid,
    });

    print('Response details saved to Firestore');
  } catch (e) {
    print('Error saving response details to Firestore: $e');

    if (e is FirebaseException) {
      print('Firestore Error Code: ${e.code}');
      print('Firestore Error Message: ${e.message}');
      if (e.code == 'permission-denied') {
        print(
            'Firestore Permission Denied: Make sure Firestore rules allow write access.');
      }
    }
  }
}

Future<Map<String, dynamic>> fetchGPTResponse(String prompt) async {
  final response = await http.post(
    Uri.parse(OpenAIConfig.apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a helpful nutritional assistant that creates dish recipes, first you give the dish name at any cost with sperate heading "Dish Name", then you give ingidients with quanties under sperate heading  "Ingredients" keeping the ingrideints to maximum limit of 5 words and then with short instructions maximum of 5 lines and for each line maximum 10 words short sentences with only given ingrideints,do not add extra ingridients except for minimum herbs but no major edible items under the heading "Instructions" and for that dish you create you also provide calories and fats approximations only in metrics in seperate heading  "Calories"',
        },
        {
          'role': 'user',
          'content': 'ingridients: $prompt',
        },
      ],
      'max_tokens': 3000, // Adjust max tokens as needed
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    final responseMap = <String, String>{};
    jsonResponse.forEach((key, value) {
      responseMap[key] = value.toString();
    });

    // Pass the responseMap to saveResponseToJson

    final assistantMessage = jsonResponse['choices'][0]['message']['content'];
    print('Assistant Message: $assistantMessage');

    final headings = ["Dish Name", "Ingredients", "Instructions", "Calories"];
    final sections = <String>[];

    for (var i = 0; i < headings.length; i++) {
      final currentHeading = headings[i];
      final nextHeading = (i < headings.length - 1) ? headings[i + 1] : null;

      final startIndex = assistantMessage.indexOf(currentHeading);
      final endIndex = (nextHeading != null)
          ? assistantMessage.indexOf(nextHeading)
          : assistantMessage.length;

      final sectionContent =
          assistantMessage.substring(startIndex, endIndex).trim();

      sections.add(sectionContent);
    }

    String dishName = '';
    String ingredientsList = '';
    String nutritionalInfo = '';
    String instructions = '';

    if (sections.length >= 4) {
      dishName = sections[0];
      ingredientsList = sections[1];
      nutritionalInfo = sections[3];
      instructions = sections[2];
    }
    sharedUUID = generateSharedUUID();
    print('Shared uuID: $sharedUUID');
    dishName_img = dishName;

    Image? image;

    try {
      image = await generateImageFromHuggingFace(dishName);
    } catch (exception) {
      // Handle image fetching exceptions
      print('Error fetching image: $exception');
      // Store the exception for later use, if needed
      _imageFetchingException = exception;
    } //dalle image gneration from dishname
    //print('Generated Image URL: $imageUrl');

    String userId = user!.uid;
    print('User ID: $userId');

    final response1 = {
      'userId': userId, // Add the user ID to the response
      'dishName': dishName,
      'ingredientsList': ingredientsList,
      'nutritionalInfo': nutritionalInfo,
      'instructions': instructions,
      'shareduid': sharedUUID
    };

    // Save the response to Firestore
    await saveResponseToFirestore(userId, sharedUUID, response1);

    return {
      'dishName': dishName,
      'ingredientsList': ingredientsList,
      'nutritionalInfo': nutritionalInfo,
      'instructions': instructions,
      'image': image,
    };
  } else {
    print('API Error - Status Code: ${response.statusCode}');
    print('API Response Body: ${response.body}');
    throw Exception('Failed to load GPT-3 response');
  }
}

Future<Map<String, dynamic>> getGPTResponseFromUserInput(
    String userInputPrompt) async {
  final gptResponse = await fetchGPTResponse(userInputPrompt);
  return gptResponse;
}
