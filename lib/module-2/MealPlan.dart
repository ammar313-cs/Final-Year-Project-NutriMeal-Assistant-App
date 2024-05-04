// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, use_build_context_synchronously, avoid_print, depend_on_referenced_packages, unused_import, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, non_constant_identifier_names, unused_field, avoid_function_literals_in_foreach_calls, unused_local_variable, use_rethrow_when_possible, prefer_typing_uninitialized_variables, prefer_final_fields

import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:nutrimeal/app_bar/app_bar.dart';
import 'package:nutrimeal/module-2/MealInputWidget.dart';
import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img1;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class WeeklyMealPlanPage extends StatefulWidget {
  final Map<String, List<String>> mealPlan;

  WeeklyMealPlanPage({required this.mealPlan});

  @override
  _WeeklyMealPlanPageState createState() => _WeeklyMealPlanPageState();
}

class _WeeklyMealPlanPageState extends State<WeeklyMealPlanPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Random _random = Random();
  int generateRandomNumber() {
    // Generate a random number between 1 and 11 (inclusive)
    return _random.nextInt(7) + 1;
  }

  Widget Downlaod_Float_button(
      BuildContext context, Map<String, List<String>> mealPlan) {
    return Positioned(
      bottom: 20.0,
      right: 20.0,
      child: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          showDownloadConfirmationDialog(context);
        },
        heroTag: "btn1",
        tooltip: 'Download button',
        child: Icon(
          Icons.download,
          color: Colors.white,
        ),
      ),
    );
  }

  void showDownloadConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Download Confirmation'),
          content: Text('Are you sure you want to download this meal plan?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _downloadMealPlan(widget.mealPlan);
              },
              child: Text('Download'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadMealPlan(Map<String, List<String>> mealPlan) async {
    try {
      // Convert meal plan to a text format
      String mealPlanText = _convertMealPlanToText(mealPlan);

      // Create a ParagraphBuilder to calculate text dimensions
      ui.ParagraphBuilder builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: 35.0,
          textDirection: TextDirection.ltr,
        ),
      );
      builder.addText(mealPlanText);
      ui.Paragraph paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: 780));

      // Calculate the required image dimensions based on text size
      double textHeight = paragraph.height;
      double textWidth = paragraph.width;
      double desiredImageWidth = textWidth + 20; // Add padding
      double desiredImageHeight = textHeight + 20; // Add padding

      // Create an empty image with calculated dimensions
      img1.Image image = img1.Image(
        desiredImageWidth.toInt(),
        desiredImageHeight.toInt(),
      );

      // Create a PictureRecorder to record drawing commands
      ui.PictureRecorder recorder = ui.PictureRecorder();
      ui.Canvas canvas = ui.Canvas(recorder);

      // Create a Paint object for the gradient background
      Paint gradientPaint = Paint()
        ..shader = ui.Gradient.linear(
          const ui.Offset(0, 0),
          ui.Offset(desiredImageWidth, desiredImageHeight),
          [secondaryColor, primaryColor],
          [0.4, 0.7],
          TileMode.repeated,
        );

      // Draw the gradient background on the canvas
      canvas.drawRect(
        Rect.fromLTWH(0, 0, desiredImageWidth, desiredImageHeight),
        gradientPaint,
      );
      // Load the logo image from assets
      ui.Image logoImage =
          await _loadImageFromAssets('assets/icons/NutriLogo.png');

      // Resize the logo image
      double logoScaleFactor = 0.3; // Adjust this factor as needed
      ui.Image resizedLogoImage = await _resizeImage(
          logoImage,
          (desiredImageWidth * logoScaleFactor).toInt(),
          (desiredImageHeight * logoScaleFactor).toInt());

      // Calculate the position to place the logo at the right-middle of the image
      final double logoX =
          (desiredImageWidth - resizedLogoImage.width.toDouble()) / 2;
      final double logoY =
          (desiredImageHeight - resizedLogoImage.height.toDouble()) / 2;

      // Draw the logo onto the canvas
      canvas.drawImage(resizedLogoImage, Offset(logoX, logoY), Paint());

      // Add meal plan text to the image
      ui.ParagraphBuilder textBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: 35.0,
          fontWeight: FontWeight.bold,
          textDirection: TextDirection.ltr,
        ),
      );
      textBuilder.addText(mealPlanText);
      ui.Paragraph textParagraph = textBuilder.build()
        ..layout(ui.ParagraphConstraints(width: 780));

      // Draw the paragraph onto the canvas
      canvas.drawParagraph(textParagraph, const ui.Offset(10, 10));

      // Convert the recorded picture into an image
      ui.Image mealPlanImageUi = await recorder.endRecording().toImage(
            image.width,
            image.height,
          );

      // Convert the ui.Image directly to bytes
      ByteData? byteData =
          await mealPlanImageUi.toByteData(format: ui.ImageByteFormat.png);
      Uint8List mealPlanImageBytes = byteData!.buffer.asUint8List();

      Directory? directory = await getExternalStorageDirectory();

      final result = await ImageGallerySaver.saveImage(mealPlanImageBytes);

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Meal plan downloaded successfully and saved to gallery!'),
            duration: Duration(seconds: 2), // Adjust as needed
          ),
        );
      } else {
        SnackBar(
          content: Text('Failed to save image to gallery!'),
          duration: Duration(seconds: 4), // Adjust as needed
        );
        throw 'Failed to save image to gallery';
      }
    } catch (e) {
      print('Error downloading meal plan: $e');
      // Return failure
      throw e;
    }
  }

  Future<ui.Image> _loadImageFromAssets(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<ui.Image> _resizeImage(
      ui.Image image, int desiredWidth, int desiredHeight) async {
    // Create a new empty image with the desired dimensions
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = ui.Canvas(recorder)
      ..drawImageRect(
        image,
        Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTRB(0, 0, desiredWidth.toDouble(), desiredHeight.toDouble()),
        Paint(),
      );

    // End the recording and convert it to an image
    ui.Image resizedImage = await recorder.endRecording().toImage(
          desiredWidth,
          desiredHeight,
        );

    return resizedImage;
  }

  String _convertMealPlanToText(Map<String, List<String>> mealPlan) {
    StringBuffer stringBuffer = StringBuffer();
    mealPlan.forEach((day, meals) {
      stringBuffer.writeln(day);
      meals.forEach((meal) {
        stringBuffer.writeln(' $meal');
      });
      stringBuffer.writeln(); // Add a new line between days
    });
    return stringBuffer.toString();
  }

  var img;
  var img_array = List.filled(7, 0);

  final Color primaryColor = Colors.purple;
  final Color secondaryColor = Colors.redAccent;

  late List<String> _selectedDayMeals;

  @override
  void initState() {
    super.initState();
    // Initialize _selectedDayMeals with the first day's meals
    _selectedDayMeals = widget.mealPlan.entries.first.value;
    img = generateRandomNumber();

    for (int i = 0; i < 7; i++) {
      img_array[i] = generateRandomNumber();
    }
  }

  Future<void> _refresh() async {
    // Simulate a delay for refreshing
    await Future.delayed(Duration(seconds: 2));

    // Generate new random numbers for images
    setState(() {
      img = generateRandomNumber();
      for (int i = 0; i < 7; i++) {
        img_array[i] = generateRandomNumber();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.mealPlan.length,
      child: Scaffold(
        floatingActionButton: Downlaod_Float_button(context, widget.mealPlan),
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        appBar: CustomAppBarWithDrawer(scaffoldKey: _scaffoldKey),
        drawer: CustomDrawer(),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.4, 0.7],
                tileMode: TileMode.repeated,
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black, //  background color
                    border: Border(
                        bottom: BorderSide(color: Colors.black, width: 0)),
                  ),
                  child: TabBar(
                    labelColor: Colors.redAccent,
                    unselectedLabelColor: Colors.white,
                    indicatorColor: Colors.white,
                    isScrollable: true,
                    tabs: widget.mealPlan.keys.map((day) {
                      return Tab(text: day);
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: widget.mealPlan.values.map((meals) {
                      int i = generateRandomNumber() - 1;

                      return _buildDayContent(meals, img_array[i]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayContent(List<String> meals, var img1) {
    bool hasBreakfast = false;
    bool hasLunch = false;
    bool hasDinner = false;
    bool hasSnack = false;

    if (globalMealval == 4) {
      hasBreakfast = true;
      hasLunch = true;
      hasDinner = true;
      hasSnack = true;
    } else if (globalMealval == 3) {
      hasBreakfast = true;
      hasLunch = true;
      hasDinner = true;
    } else if (globalMealval == 2) {
      hasBreakfast = true;
      hasLunch = true;
    } else {
      hasBreakfast = true;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          if (hasBreakfast)
            Column(
              children: [
                _buildMealTile(
                  'Breakfast',
                  meals,
                  Image.asset(
                    'assets/images/Breakfast/$img1.jpg',
                  ),
                ),
                SizedBox(height: 20),
                Divider(
                  color: Colors.black,
                ), // Divider between Breakfast and other meals
              ],
            ),
          SizedBox(height: 10),
          if (hasLunch)
            Column(
              children: [
                _buildMealTile(
                  'Lunch',
                  meals,
                  Image.asset(
                    'assets/images/Lunch/$img1.jpg',
                  ),
                ),
                SizedBox(height: 20),
                Divider(
                  color: Colors.black,
                ), // Divider between Lunch and other meals
              ],
            ),
          SizedBox(height: 10),
          if (hasDinner)
            Column(
              children: [
                _buildMealTile(
                  'Dinner',
                  meals,
                  Image.asset(
                    'assets/images/Dinner/$img1.jpg',
                  ),
                ),
                SizedBox(height: 10),
                if (hasSnack)
                  Column(
                    children: [
                      Divider(
                        color: Colors.black,
                      ), // Divider between Dinner and Snack
                      SizedBox(height: 10),
                      _buildMealTile(
                        'Snack',
                        meals,
                        Image.asset(
                          'assets/images/Snacks/$img1.jpg',
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMealTile(String mealType, List<String> meals, Image imagevar) {
    List<String> mealNames = meals
        .where((meal) => meal.toLowerCase().contains(mealType.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          mealType,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            decoration: TextDecoration.underline, // Add underline
          ),
        ),
        Divider(
          color: Colors.black,
        ),
        SizedBox(height: 10),
        for (String mealName in mealNames) ...[
          Text(
            mealName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          SizedBox(height: 10), // Added spacing between text and image
          Container(
            height: 200,
            width: 370, // Increase width
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.1), // Reduce opacity on sides
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image(
                image: imagevar.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
