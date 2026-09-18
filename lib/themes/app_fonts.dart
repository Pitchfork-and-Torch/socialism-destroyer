import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography helpers that avoid Google Fonts CDN fetches on web.
abstract final class AppFonts {
  /// VM/widget tests use system fonts — Google Fonts network I/O breaks goldens.
  @visibleForTesting
  static bool forceSystemFonts = false;

  /// Call from [initTestEnvironment] before pumping widgets.
  @visibleForTesting
  static void configureForTests() {
    forceSystemFonts = true;
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  static bool get _useSystemFonts => kIsWeb || forceSystemFonts;

  static const _interFallback = [
    'Segoe UI',
    'system-ui',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  static const _serifFallback = [
    'Georgia',
    'Times New Roman',
    'serif',
  ];

  static void configure() {
    if (kIsWeb) {
      GoogleFonts.config.allowRuntimeFetching = false;
    }
  }

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
    FontStyle? fontStyle,
  }) {
    if (_useSystemFonts) {
      return TextStyle(
        fontFamily: 'Segoe UI',
        fontFamilyFallback: _interFallback,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        fontStyle: fontStyle,
      );
    }
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontStyle: fontStyle,
    );
  }

  static TextStyle libreBaskerville({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
    FontStyle? fontStyle,
  }) {
    if (_useSystemFonts) {
      return TextStyle(
        fontFamily: 'Georgia',
        fontFamilyFallback: _serifFallback,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        fontStyle: fontStyle,
      );
    }
    return GoogleFonts.libreBaskerville(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontStyle: fontStyle,
    );
  }

  static TextStyle lora({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    Color? color,
    FontStyle? fontStyle,
  }) {
    if (_useSystemFonts) {
      return TextStyle(
        fontFamily: 'Georgia',
        fontFamilyFallback: _serifFallback,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        color: color,
        fontStyle: fontStyle,
      );
    }
    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      fontStyle: fontStyle,
    );
  }

  static TextStyle playfairDisplay({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    Color? color,
    FontStyle? fontStyle,
  }) {
    if (_useSystemFonts) {
      return TextStyle(
        fontFamily: 'Georgia',
        fontFamilyFallback: _serifFallback,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        color: color,
        fontStyle: fontStyle,
      );
    }
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      fontStyle: fontStyle,
    );
  }
}