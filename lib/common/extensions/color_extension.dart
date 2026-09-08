import 'package:flutter/material.dart';

mixin HexColor on Color {
  static Color fromHex(String hexCode) {
    final buffer = StringBuffer();

    if (hexCode.length == 6 || hexCode.length == 7) buffer.write('ff');
    buffer.write(hexCode.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Color darken(double percent) {
    assert(0 <= percent && percent <= 1, 'percent must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    final darkenedHsl = hsl.withLightness(hsl.lightness - percent);
    return darkenedHsl.toColor();
  }

  /// Lightens a color by the given [percent].
  Color lighten(double percent) {
    assert(0 <= percent && percent <= 1, 'percent must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    final lightenedHsl = hsl.withLightness(hsl.lightness + percent);
    return lightenedHsl.toColor();
  }

  /// Creates a shade of the color by the given [shade] value.
  Color shade(double shade) {
    assert(-1 <= shade && shade <= 1, 'shade must be between -1 and 1');
    if (shade > 0) {
      return lighten(shade);
    } else if (shade < 0) {
      return darken(-shade);
    } else {
      return this;
    }
  }

  static Color get succesColor => const Color(0xff008000);
  static Color get primaryColor => const Color.fromRGBO(81, 82, 221, 1);
  static Color get errorColor => const Color(0xffFF0000);
  static Color get greyColor => const Color(0xff6B7280);
}
