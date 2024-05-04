// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_field, unused_import, unused_element, avoid_print, prefer_final_fields, use_key_in_widget_constructors, unnecessary_nullable_for_final_variable_declarations, deprecated_member_use, unused_local_variable, prefer_interpolation_to_compose_strings, prefer_const_declarations, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nutrimeal/app_bar/app_bar.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:nutrimeal/module-2/api_helper.dart';
import 'MealInputWidget.dart';

List<String> edibleItems = [];

bool? apiStateCheck;
bool? clasifyapistateCheck;
bool? cleanStateapiCheck;

class OCRScreen extends StatefulWidget {
  @override
  OCRScreenState createState() => OCRScreenState();
}

class OCRScreenState extends State<OCRScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Color primaryColor = Colors.purple;
  final Color secondaryColor = Colors.redAccent;

  File? _image;
  InputImage? _inputimage;

  bool _showFilePicker = false;
  late String _selectedFilePath = '';

  List<String> resultList = []; //Result from ocr being stored

  ApiHelper apiHelper = ApiHelper();

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        if (['png', 'jpg', 'jpeg'].contains(file.extension?.toLowerCase())) {
          String newSelectedFilePath = file.path!;
          setState(() {
            _selectedFilePath = newSelectedFilePath;
            _inputimage = InputImage.fromFilePath(newSelectedFilePath);
            _showFilePicker = false;
          });

          // Process the result and send it for cleaning and classification
          await imageToText(_inputimage);

          try {
            Map<String, dynamic> results_cleaned =
                await apiHelper.cleanData(resultList);
            cleanStateapiCheck = true;

            print("\n");
            print("Cleaned data result: $results_cleaned");

            List<String> _convertedResult =
                apiHelper.convertMapToList(results_cleaned);

            print("\n");
            print("Converted data result: $_convertedResult");

            Map<String, dynamic> results_classified =
                await apiHelper.classifyItems(_convertedResult);
            clasifyapistateCheck = true;

            print("\n");
            print("Classified data result: $results_classified");
            List<String> classificationResults = (results_classified[
                    'classification_results'] as List<dynamic>)
                .cast<String>(); // Add this line to cast each element to String

            List<String> edibleResults = classificationResults
                .where((result) => result.endsWith('Edible'))
                .where((result) => !result.contains('NonEdible'))
                .map((result) => result.replaceAll(' Edible', ''))
                .toList();

            String formattedEdibleItems = edibleResults.join('\\n');
            print("\n");
            print("Edible Items: $formattedEdibleItems");

            setState(() {
              apiStateCheck = true;
              edibleItems = formattedEdibleItems.split('\\n');
            });
          } catch (e) {
            apiStateCheck = false;
            clasifyapistateCheck = false;
            cleanStateapiCheck = false;
            _showErrorSnackbar('An error occurred: $e');
          }
        } else {
          apiStateCheck = false;
          clasifyapistateCheck = false;
          cleanStateapiCheck = false;
          _showErrorSnackbar(
              'Invalid file format. Please select a PNG, JPG, or JPEG file.');
        }
      } else {
        apiStateCheck = false;
        clasifyapistateCheck = false;
        cleanStateapiCheck = false;
        print('File picking canceled');
      }
    } catch (e) {
      apiStateCheck = false;
      clasifyapistateCheck = false;
      cleanStateapiCheck = false;
      print('Error picking file: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("Error Get a cleaner picture and select the right image!!"),
        duration: Duration(seconds: 5),
      ),
    );
  }

  Widget _displayPickedImage() {
    return Container(
      width: 2 * 96.0,
      height: 2 * 96.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        image: _selectedFilePath.isNotEmpty
            ? DecorationImage(
                image: FileImage(File(_selectedFilePath)),
                fit: BoxFit.cover,
              )
            : null,
      ),
    );
  }

  Future<void> imageToText(inputImage) async {
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText visionText =
        await textDetector.processImage(inputImage);

    setState(() {
      resultList = []; // Reset resultList before processing new image

      for (TextBlock block in visionText.blocks) {
        for (TextLine line in block.lines) {
          String result = ""; // Initialize result for each line

          for (TextElement element in line.elements) {
            result += element.text + " ";
          }

          resultList.add(result.trim());
        }
      }

      print("Full Result Format: ${resultList}");
    });
  }

  Widget _filePickerWidget() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _pickFile();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
          ),
          icon: Icon(
            Icons.image,
            color: Colors.white,
          ),
          label: Text(
            'Pick Grocery List',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        _displayPickedImage(),
      ],
    );
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [secondaryColor, primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.4, 0.7],
            tileMode: TileMode.repeated,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 70.0,
              horizontal: 70.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _filePickerWidget(),
                SizedBox(
                  height: 30.0,
                ),
                MealInputWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
