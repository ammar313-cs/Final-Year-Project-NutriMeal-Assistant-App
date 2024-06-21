// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names, avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  final apiUrl_clean = '';
  final apiUrl_classify = '';

  List<String> convertMapToList(Map<String, dynamic> inputMap) {
    return inputMap.values.map((dynamic value) => value.toString()).toList();
  }

  Future<Map<String, dynamic>> cleanData(List<String> _uncleanedData) async {
    // Preparing the data in the required format
    Map<String, dynamic> data = {};

    // Mapping the items to keys with numbers from 1 till n
    for (int i = 0; i < _uncleanedData.length; i++) {
      data['key${i + 1}'] = _uncleanedData[i];
    }

    // Encoding the data to JSON
    String jsonData = jsonEncode(data);

    try {
      // Sending a POST request to the API endpoint
      final response = await http.post(
        Uri.parse(apiUrl_clean),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      //  successful (status code 200)
      if (response.statusCode == 200) {
        // Decoding the JSON response
        Map<String, dynamic> result = jsonDecode(response.body);
        return result;
      } else {
        // If the request  not successful, throw  exception
        throw Exception(
            'Failed to classify items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handles any exceptions that may occur during the request
      print('Error: $e');
      throw Exception('Failed to classify items. Error: $e');
    }
  }

  Future<Map<String, dynamic>> classifyItems(
      List<String> _cleanedData_for_classify) async {
    // Preparing the data in the required format
    Map<String, dynamic> data = {"items": _cleanedData_for_classify};

    try {
      // Sending a POST request to the API endpoint
      final response = await http.post(
        Uri.parse(apiUrl_classify),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      // successful (status code 200)
      if (response.statusCode == 200) {
        // Decodes the JSON response
        Map<String, dynamic> result = jsonDecode(response.body);
        return result;
      } else {
        // If the request  not successful, throws an exception
        throw Exception(
            'Failed to classify items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handles any exceptions that may occur during the request
      print('Error: $e');
      throw Exception('Failed to classify items. Error: $e');
    }
  }
}
