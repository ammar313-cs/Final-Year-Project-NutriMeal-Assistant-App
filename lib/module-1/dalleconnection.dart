import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrimeal/Reg_screens/login_screen.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'gptconnection.dart';

class OpenAIConfig {
  static const String apiUrl =
      "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0"; // Updated API endpoint
  static const String apiKey =
      "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"; // Replace with your actual API key
}

Future<void> saveImageToFirebaseStorage(
  Uint8List imageBytes,
  String userId,
  String sharedUUID,
) async {
  try {
    // Format the current date and time
    String timestamp = DateTime.now().toUtc().toIso8601String();

    // Create a unique filename for the image using date, time, user ID, and UUID
    String imageName = 'image_${timestamp}_${userId}_${sharedUUID}.jpg';

    // Upload image to Firebase Storage
    final storageRef =
        firebase_storage.FirebaseStorage.instance.ref('images/$imageName');
    await storageRef.putData(imageBytes); //exception

    // Retrieve the download URL for the uploaded image
    String downloadURL = await storageRef.getDownloadURL();

    // Save image details to Firestore
    await saveImageDetailsToFirestore(userId, sharedUUID, downloadURL);

    print('Image details saved to Firestore');
  } catch (e) {
    print('Error saving image to Firebase Storage: $e');
    // Add more specific error handling based on the error type
    if (e is firebase_storage.FirebaseException) {
      print('Firebase Storage Error Code: ${e.code}');
      print('Firebase Storage Error Message: ${e.message}');
    }
  }
}

Future<void> saveImageDetailsToFirestore(
  String userId,
  String sharedUUID,
  String imageUrl,
) async {
  try {
    final userImageCollection = FirebaseFirestore.instance
        .collection('user_images')
        .doc(userId)
        .collection('images');

    await userImageCollection.doc(sharedUUID).set({
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'shareduid': sharedUUID,
      'dishName': dishName_img,
    });

    print('Image details saved to Firestore');
  } catch (e) {
    print('Error saving image details to Firestore: $e');

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

Future<Image> generateImageFromHuggingFace(String prompt) async {
  final completer = Completer<Image>();

  try {
    final response = await http.post(
      Uri.parse(OpenAIConfig.apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
      },
      body: jsonEncode({
        // Modify the request payload for Hugging Face if needed
        'inputs': prompt, // Use 'inputs' for Hugging Face models
        // Add other parameters as needed
      }),
    );

    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;

      // Create an Image widget to display the image
      final imageWidget = Image.memory(
        Uint8List.fromList(imageBytes),
        // Add other properties like width, height, fit, etc. if needed
      );

      completer.complete(imageWidget);

      String userId = user!.uid; // uid of user logged in
      String uuid = sharedUUID;

      await saveImageToFirebaseStorage(imageBytes, userId, uuid);
    } else {
      print('Hugging Face API Error - Status Code: ${response.statusCode}');
      print('Hugging Face API Response Body: ${response.body}');
      completer.completeError(
          Exception('Failed to generate image from Hugging Face model'));
    }
  } catch (e) {
    print('Error generating image from Hugging Face model: $e');
    completer.completeError(
        Exception('Failed to generate image from Hugging Face model'));
  }

  return completer.future;
}
