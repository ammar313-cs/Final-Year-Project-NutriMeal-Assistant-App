// ignore_for_file: prefer_const_constructors, avoid_print, non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Reg_screens/login_screen.dart';

class ImageData {
  final String dishName;
  final String imageUrl;
  final String sharedUid;
  final Timestamp timestamp;

  ImageData({
    required this.dishName,
    required this.imageUrl,
    required this.sharedUid,
    required this.timestamp,
  });
}

Future<List<ImageData>> fetchImageUrls() async {
  String userId = user!.uid; // Replace with the actual user ID

  QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
      .instance
      .collection('user_images')
      .doc(userId)
      .collection('images')
      .get();

  List<ImageData> imageList = [];

  for (QueryDocumentSnapshot<Map<String, dynamic>> document in snapshot.docs) {
    var dishName = document.data()['dishName'];
    var imageUrl = document.data()['imageUrl'];
    var sharedUid = document.data()['shareduid'];
    var timestamp = document.data()['timestamp'];

    if (dishName != null &&
        imageUrl != null &&
        sharedUid != null &&
        timestamp != null) {
      imageList.add(ImageData(
        dishName: dishName,
        imageUrl: imageUrl,
        sharedUid: sharedUid,
        timestamp: timestamp,
      ));
    }
  }

  return imageList;
}

Future<Map<String, dynamic>?> fetchResponseFromFirebase(
    String uid, String sharedUUID) async {
  try {
    // Creating a Firestore reference for the user's response
    final userResponseDocument = FirebaseFirestore.instance
        .collection('user_responses')
        .doc(uid) // user's ID in the document ID
        .collection('responses')
        .doc(sharedUUID); // sharedUUID in the document ID

    // Get the document from Firestore
    DocumentSnapshot responseDocument = await userResponseDocument.get();

    // Print the document data for further inspection

    // Check if the document exists and return the data
    if (responseDocument.exists) {
      return responseDocument.data() as Map<String, dynamic>;
    } else {
      print('Document not found for sharedUUID: $sharedUUID');
      return null;
    }
  } catch (e) {
    print('Error fetching response from Firestore: $e');
    if (e is FirebaseException) {
      print('Firestore Error Code: ${e.code}');
      print('Firestore Error Message: ${e.message}');
      if (e.code == 'permission-denied') {
        print(
            'Permission Denied: Make sure Firestore rules allow read access.');
      }
    }
    return null;
  }
}

Future<void> deleteImageAndResponse(String userId, String sharedUid) async {
  try {
    // Delete image from "user_images" collection
    await FirebaseFirestore.instance
        .collection('user_images')
        .doc(userId)
        .collection('images')
        .doc(sharedUid)
        .delete();

    print(
        'Image deleted from user_images collection for sharedUid: $sharedUid');

    // Delete response from "user_responses" collection
    await FirebaseFirestore.instance
        .collection('user_responses')
        .doc(userId)
        .collection('responses')
        .doc(sharedUid)
        .delete();

    print(
        'Response deleted from user_responses collection for sharedUid: $sharedUid');
  } catch (e) {
    print('Error deleting image and response: $e');
    if (e is FirebaseException) {
      print('Firestore Error Code: ${e.code}');
      print('Firestore Error Message: ${e.message}');
      if (e.code == 'permission-denied') {
        print(
            'Permission Denied: Make sure Firestore rules allow write access.');
      }
    }
  }
}

void history_popup(
  BuildContext context,
  Map<String, dynamic>? responseInfo,
  Function() refreshUI,
) {
  // Check if the responseInfo is null
  if (responseInfo == null) {
    print('Response info is null');
    return;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.all(1.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.redAccent],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              stops: [0.4, 0.7],
              tileMode: TileMode.repeated,
            ),
          ),
          width: MediaQuery.of(context).size.width - 2.0,
          height: MediaQuery.of(context).size.height - 2.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Image.asset(
                  'assets/icons/NutriLogo.png',
                  width: 100.0,
                  height: 100.0,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            'Dish Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            responseInfo['dishName'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Ingredients List',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            responseInfo['ingredientsList'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Nutritional Info',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            responseInfo['nutritionalInfo'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Instructions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            responseInfo['instructions'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        String userId = responseInfo['userId'];
                        String shareduuid = responseInfo['sharedUid'];
                        await deleteImageAndResponse(userId, shareduuid);
                        refreshUI();
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
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
                      child: Text('Delete'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
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
                      child: Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
