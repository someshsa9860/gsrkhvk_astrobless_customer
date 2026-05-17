import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:callvcal/utils/global.dart' as global;

class AutocompletePrediction {
  final String? description;
  final String? placeId;
  final String? primaryText;

  AutocompletePrediction({this.description, this.placeId, this.primaryText});

  factory AutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return AutocompletePrediction(
      description: json['description'],
      placeId: json['place_id'],
    );
  }
}

class SearchPlaceController extends GetxController {
  double? latitude;
  double? longitude;
  List<AutocompletePrediction>? predictions = [];
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> autoCompleteSearch(String? value) async {
    debugPrint("Search place value ${value}");
    if (value != null && value.isNotEmpty) {
      try {
        final apiKey = global
            .getSystemFlagValue(global.systemFlagNameList.googleMapApiKey);

        final url =
            'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&key=$apiKey';
        debugPrint("Search place value ${apiKey}");
        final response = await http.get(Uri.parse(url));
        final data = json.decode(response.body);

        // log('API Response: ${response.body}');
        // log('API Response: ${response.statusCode}');

        if (data['status'] == 'OK') {
          predictions = (data['predictions'] as List)
              .map((item) => AutocompletePrediction.fromJson(item))
              .toList();
        } else {
          predictions = [];
          log('Places API error: ${data['status']}');
        }

        update();
      } catch (e,s) {
              print(s);
        debugPrint('Error fetching places: $e');
        predictions = [];
        update();
      }
    } else {
      predictions = [];
      update();
    }
  }
}
