import 'package:flutter/material.dart';

class KundliGender{
  dynamic title;
  bool isSelected;
  dynamic image;
  KundliGender({required this.title,required this.isSelected,required this.image});
}

class Kundli{
  IconData icon;
  bool isSelected;
  Kundli({required this.icon,required this.isSelected});
}
class KundliDetailTab{
  dynamic title;
  bool isSelected;
  KundliDetailTab({required this.title,required this.isSelected});
}

class KundliDetails{
  dynamic title;
  dynamic value;
  KundliDetails({required this.title,required this.value});
}