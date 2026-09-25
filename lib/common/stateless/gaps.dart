import 'package:flutter/material.dart';

abstract interface class Gaps {
  const Gaps._();

  static SizedBox v(double value) => SizedBox(height: value);
  static SizedBox h(double value) => SizedBox(width: value);
  static SizedBox square(double size) => SizedBox(width: size, height: size);
  static SizedBox v10() => const SizedBox(height: 10);
  static SizedBox v18() => const SizedBox(height: 18);
  static SizedBox h10() => const SizedBox(width: 10);
  static SizedBox h18() => const SizedBox(width: 18);
  static SizedBox h25() => const SizedBox(width: 25);
  static SizedBox v25() => const SizedBox(height: 25);
  static SizedBox square10() => const SizedBox(width: 10, height: 10);
}
