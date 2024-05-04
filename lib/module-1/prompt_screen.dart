// ignore_for_file: prefer_const_constructors, duplicate_ignore, use_build_context_synchronously, unused_import, sized_box_for_whitespace, non_constant_identifier_names, unused_element, use_key_in_widget_constructors, prefer_final_fields, no_leading_underscores_for_local_identifiers, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:nutrimeal/Reg_screens/login_screen.dart';
import 'package:nutrimeal/app_bar/app_bar.dart';
import 'package:nutrimeal/main.dart';
import 'package:nutrimeal/module-1/fetch_img_data.dart';
import '../gamification/gamififcation.dart';
import 'gptconnection.dart';

import 'package:nutrimeal/gamification/M1game.dart';

Nutripoints nutripoints = Nutripoints(
  username: username_global,
);

class PromptScreen extends StatefulWidget {
  @override
  PromptScreenState createState() => PromptScreenState();
}

class PromptScreenState extends State<PromptScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false; // Flag to track loading state
  String userId = user!.uid;
  void refreshUI() {
    setState(() {
      // Update any state variables or perform other tasks here if needed
    });
  }

  Future<void> _showErrorDialog(
      //error dailouge for the verification
      BuildContext context,
      String errorMessage) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text('Error Generating Recipie!'),
          content: Container(
            child: Text(
              errorMessage,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showResponsePopup(BuildContext context, Map<String, dynamic> dishInfo) {
    setState(() {
      _isLoading = false;
    });

    // Display the extracted dish information in a dialog or any other desired way
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

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.black, width: 2.0),
                    ),
                    child: Container(
                      color: Colors.black,
                      child: SizedBox(
                        width: 90.0,
                        height: 170.0,
                        child: dishInfo['image'] ?? 'N/A',
                      ),
                    ),
                  ),
                ),

                /////////////////////
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
                              dishInfo['dishName'] ?? 'N/A',
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
                              dishInfo['ingredientsList'] ?? 'N/A',
                              style: TextStyle(
                                color:
                                    Colors.black, // Black subtitle text color
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
                              dishInfo['nutritionalInfo'] ?? 'N/A',
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
                              dishInfo['instructions'] ?? 'N/A',
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
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmission() async {
    setState(() {
      _isLoading = true; // Show loading indicator when submitting
    });

    final userInputPrompt = _inputController.text;
    final gptResponse = await getGPTResponseFromUserInput(userInputPrompt);

    // Showing the response popup with a delay to simulate the loading
    // Replaced the delay with the actual loading time
    await Future.delayed(Duration(seconds: 5));

    _showResponsePopup(context, gptResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: CustomAppBarWithDrawer(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.redAccent],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: [0.4, 0.7],
            tileMode: TileMode.repeated,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 70),
                Center(
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.8, // Adjust the width as needed
                      height: 150,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(30.0), // Rounded corners
                        ),
                        child: TextFormField(
                          controller: _inputController,
                          maxLines: null,
                          // ignore: prefer_const_constructors
                          decoration: InputDecoration(
                            labelText: 'Enter Ingredients',
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(Icons.input, color: Colors.black),
                            border: InputBorder.none,
                            fillColor: Colors.transparent,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  20.0, // Increase vertical padding to increase height
                              horizontal:
                                  30.0, // Decrease horizontal padding to decrease width
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 60.0, // Set the desired height
                  width: 100.0, // Set a constant small width
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            30.0, // Adjust the radius for the desired roundness
                          ),
                        ),
                      ),
                      side: MaterialStateProperty.all<BorderSide>(
                        BorderSide.none, // Remove the border side
                      ),
                      backgroundColor: MaterialStateProperty.all<Color?>(
                        Colors.black, // Set the background to black
                      ),
                      elevation: MaterialStateProperty.all<double>(
                        10.0, // Add shadow
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            final userInputPrompt = _inputController.text;
                            setState(() {
                              _isLoading =
                                  true; // Show loading indicator when submitting
                            });
                            dynamic gptResponse;
                            try {
                              gptResponse = await getGPTResponseFromUserInput(
                                  userInputPrompt);
                            } catch (_imageFetchingException) {
                              _showErrorDialog(
                                  context, 'Error please try later.');
                            }
                            setState(() {
                              _isLoading =
                                  false; // Hide loading indicator when data arrives
                            });

                            _showResponsePopup(context, gptResponse);

                            M1gamepopups m1GamePopups = M1gamepopups(
                              nutripoints,
                              previousStars: nutripoints.totalStars,
                            );
                            m1GamePopups.nutripoints.pointsCosumeM1();

                            print(
                                "updates of m1scores:${m1GamePopups.nutripoints.pointsM1}\n");
                            print(
                                "updates of stars:${m1GamePopups.nutripoints.totalStars}\n");
                            print(
                                "updates of total scores:${m1GamePopups.nutripoints.totalPoints}\n");

                            m1GamePopups.showM1GamePopup(context);
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading)
                          CircularProgressIndicator() // Show loading indicator
                        else
                          Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white, // Text color is white
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      'Cuisine History ',
                      style: TextStyle(
                        fontSize: 24.0, // Adjust the font size as needed
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30.0,
                      horizontal: 40.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: <Widget>[
                        FutureBuilder<List<ImageData>>(
                          future: fetchImageUrls(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.data == null ||
                                snapshot.data!.isEmpty) {
                              return Text('No images available.');
                            } else {
                              List<ImageData> imageList = snapshot.data!;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: List.generate(
                                  (imageList.length / 2).ceil(),
                                  (index) {
                                    int startIndex = index * 2;
                                    int endIndex = (index * 2) + 1;

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            // Fetch response from Firebase
                                            final sharedUUID_of_index = imageList[
                                                    startIndex]
                                                .sharedUid; // logic to get the sharedUUID for this specific image;
                                            final responseFromFirebase =
                                                await fetchResponseFromFirebase(
                                                    userId,
                                                    sharedUUID_of_index);

                                            // Show response in a popup
                                            history_popup(
                                                context,
                                                responseFromFirebase,
                                                refreshUI);
                                          },
                                          child: Card(
                                            elevation: 5.0, // Add shadow
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      15.0), // Rounded corners
                                            ),
                                            child: Container(
                                              width:
                                                  120.0, // Adjust the size as needed
                                              height: 120.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0), // Rounded corners
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: Image.network(
                                                  imageList[startIndex]
                                                      .imageUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 14.0),
                                        if (endIndex < imageList.length)
                                          InkWell(
                                            onTap: () async {
                                              // Fetch response from Firebase
                                              final sharedUUID_of_index =
                                                  imageList[endIndex]
                                                      .sharedUid; // logic to get the sharedUUID for this specific image;
                                              final responseFromFirebase =
                                                  await fetchResponseFromFirebase(
                                                      userId,
                                                      sharedUUID_of_index);

                                              // Show response in a popup
                                              history_popup(
                                                  context,
                                                  responseFromFirebase,
                                                  refreshUI);
                                            },
                                            child: Card(
                                              elevation: 5.0, // Add shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0), // Rounded corners
                                              ),
                                              child: Container(
                                                width:
                                                    120.0, // Adjust the size as needed
                                                height: 120.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0), // Rounded corners
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: Image.network(
                                                    imageList[endIndex]
                                                        .imageUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
