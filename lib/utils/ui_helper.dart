import 'package:flutter/material.dart';

class UIHelper {
  UIHelper._();

  static TextStyle getAppBarTitleTextStyle() {
    return const TextStyle(
        fontFamily: "Raleway", fontSize: 24, fontWeight: FontWeight.bold);
  }

  static TextStyle getTitleTextStyle() {
    return const TextStyle(
        fontFamily: "Raleway", fontSize: 24, fontWeight: FontWeight.bold);
  }

  static TextStyle getRegularTextStyle() {
    return const TextStyle(
        fontFamily: "Ubuntu", fontSize: 12);
  }

  static TextStyle getButtonTextStyle() {
    return const TextStyle(fontFamily: "Ubuntu", fontSize: 14, fontWeight: FontWeight.bold);
  }

  static ButtonStyle getElevatedButtonAcceptButtonStyle() {
    return const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green), foregroundColor: WidgetStatePropertyAll(Colors.white));
  }

  static ButtonStyle getElevatedButtonRejectButtonStyle() {
    return const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red), foregroundColor: WidgetStatePropertyAll(Colors.white));
  }
  
}
