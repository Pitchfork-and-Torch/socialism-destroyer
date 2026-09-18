import 'package:equatable/equatable.dart';

/// Reader appearance — persisted locally, applied per reading session.
enum ReaderThemeMode { navy, sepia, paper }

enum ReaderFontFamily { serif, sans }

class ReaderSettings extends Equatable {
  const ReaderSettings({
    this.fontScale = 1.0,
    this.lineHeight = 1.65,
    this.themeMode = ReaderThemeMode.navy,
    this.fontFamily = ReaderFontFamily.serif,
  });

  final double fontScale;
  final double lineHeight;
  final ReaderThemeMode themeMode;
  final ReaderFontFamily fontFamily;

  static const minFontScale = 0.85;
  static const maxFontScale = 1.4;
  static const minLineHeight = 1.4;
  static const maxLineHeight = 2.0;

  ReaderSettings copyWith({
    double? fontScale,
    double? lineHeight,
    ReaderThemeMode? themeMode,
    ReaderFontFamily? fontFamily,
  }) =>
      ReaderSettings(
        fontScale: fontScale ?? this.fontScale,
        lineHeight: lineHeight ?? this.lineHeight,
        themeMode: themeMode ?? this.themeMode,
        fontFamily: fontFamily ?? this.fontFamily,
      );

  Map<String, dynamic> toJson() => {
        'fontScale': fontScale,
        'lineHeight': lineHeight,
        'themeMode': themeMode.name,
        'fontFamily': fontFamily.name,
      };

  factory ReaderSettings.fromJson(Map<String, dynamic> json) => ReaderSettings(
        fontScale: (json['fontScale'] as num?)?.toDouble() ?? 1.0,
        lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.65,
        themeMode: ReaderThemeMode.values.byName(
          json['themeMode'] as String? ?? 'navy',
        ),
        fontFamily: ReaderFontFamily.values.byName(
          json['fontFamily'] as String? ?? 'serif',
        ),
      );

  @override
  List<Object?> get props => [fontScale, lineHeight, themeMode, fontFamily];
}