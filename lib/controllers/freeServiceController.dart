import 'package:get/get.dart';

import '../model/language.dart';

class FreeServiceController extends GetxController {
  List<TabModel> freeServiceChart = [
    TabModel(title: 'Lagna Chart', isSelected: true),
    TabModel(title: 'Planetary Position', isSelected: false),
  ];

  final List<Map<String, String>> listOfPlanetPosition = [
    {"planet": "Ascendant", "rasi": "Aries", "degree": "22 \u00b0", "nakshatra": "Swati", "pada": "1"},
    {"planet": "Venus", "rasi": "Aries", "degree": "22 \u00b0", "nakshatra": "Swati", "pada": "11"},
    {"planet": "Ascendant", "rasi": "Capricorn", "degree": "22 \u00b0", "nakshatra": "Shrvana", "pada": "9"},
    {"planet": "Moon", "rasi": "Capricorn", "degree": "22 \u00b0", "nakshatra": "Swati", "pada": "10"},
    {"planet": "Ascendant", "rasi": "Capricorn", "degree": "22 \u00b0", "nakshatra": "Swati", "pada": "1"},
    {"planet": "Venus", "rasi": "Aries", "degree": "22 \u00b0", "nakshatra": "Swati", "pada": "8"},
    {"planet": "Rahu", "rasi": "Capricorn", "degree": "22 \u00b0", "nakshatra": "Swati", "pada": "1"},
    {"planet": "Rahu", "rasi": "Aries", "degree": "22 \u00b0", "nakshatra": "Swati", "pada": "1"},
    {"planet": "Ketu", "rasi": "Capricorn", "degree": "22 \u00b0", "nakshatra": "Swati", "pada": "1"},
    {"planet": "Ascendant", "rasi": "Aries", "degree": "22 \u00b0", "nakshatra": "Swati", "pada": "7"},
    {"planet": "Ascendant", "rasi": "Aries", "degree": "22 \u00b0", "nakshatra": "Swati", "pada": "1"},
    {"planet": "pluto", "rasi": "Scorpio", "degree": "22 \u00b0", "nakshatra": "Swati", "pada": "10"},
  ];
  selectChartTab(int index) {
    freeServiceChart[index].isSelected = true;
    for (int i = 0; i < freeServiceChart.length; i++) {
      if (i == index) {
        continue;
      } else {
        freeServiceChart[i].isSelected = false;
        update();
      }
    }
    update();
  }
}
