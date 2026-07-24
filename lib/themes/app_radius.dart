import 'package:flutter/material.dart';

/// Border-radius tokens aligned with Material 3 shapes.
abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;

  static BorderRadius get card => BorderRadius.circular(md);
  static BorderRadius get button => BorderRadius.circular(sm);
  static BorderRadius get chip => BorderRadius.circular(full);
  static BorderRadius get input => BorderRadius.circular(sm + 2);
}