import 'package:micro_teaching_studio/common/resources/font_manager.dart';
import 'package:flutter/material.dart';

TextStyle _getTextStyle(double fontSize, FontWeight fontWeight, Color color,
    double? height, TextDecoration? decoration) {
  return TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
      decoration: decoration);
}

// light style

TextStyle getLightStyle(
    {required double fontSize,
    required Color color,
    double? height,
    TextDecoration? decoration}) {
  return _getTextStyle(
      fontSize, FontWeightManager.light, color, height, decoration);
}

// regular style

TextStyle getRegularStyle(
    {required double fontSize,
    required Color color,
    double? height,
    TextDecoration? decoration}) {
  return _getTextStyle(
      fontSize, FontWeightManager.regular, color, height, decoration);
}

// medium style

TextStyle getMediumStyle(
    {required double fontSize,
    required Color color,
    double? height,
    TextDecoration? decoration}) {
  return _getTextStyle(
      fontSize, FontWeightManager.medium, color, height, decoration);
}

// semi bold style

TextStyle getSemiBoldStyle(
    {required double fontSize,
    required Color color,
    double? height,
    TextDecoration? decoration}) {
  return _getTextStyle(
      fontSize, FontWeightManager.semiBold, color, height, decoration);
}

// bold style

TextStyle getBoldStyle(
    {required double fontSize,
    required Color color,
    double? height,
    TextDecoration? decoration}) {
  return _getTextStyle(
      fontSize, FontWeightManager.bold, color, height, decoration);
}

TextStyle getExtraBoldStyle(
    {required double fontSize,
    required Color color,
    double? height,
    TextDecoration? decoration}) {
  return _getTextStyle(
      fontSize, FontWeightManager.extraBold, color, height, decoration);
}
