import 'package:flutter/material.dart';

// Colors that change between dark and light mode.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.text,
    required this.secondaryText,
    required this.mutedText,
    required this.headerBand,
  });

  final Color text;
  final Color secondaryText;
  final Color mutedText;
  final Color headerBand;

  static const dark = AppColors(
    text: Colors.white,
    secondaryText: Colors.white60,
    mutedText: Colors.white54,
    headerBand: Colors.white10,
  );

  static const light = AppColors(
    text: Colors.black,
    secondaryText: Colors.black54,
    mutedText: Colors.black45,
    headerBand: Colors.white54,
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? text,
    Color? secondaryText,
    Color? mutedText,
    Color? headerBand,
  }) {
    return AppColors(
      text: text ?? this.text,
      secondaryText: secondaryText ?? this.secondaryText,
      mutedText: mutedText ?? this.mutedText,
      headerBand: headerBand ?? this.headerBand,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      text: Color.lerp(text, other.text, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      headerBand: Color.lerp(headerBand, other.headerBand, t)!,
    );
  }
}

final darkTheme = _buildTheme(dark: true);
final lightTheme = _buildTheme(dark: false);

ThemeData _buildTheme({required bool dark}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue.shade900,
    surface: dark ? const Color(0xFF505050) : null,
  );
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor:
        dark ? colorScheme.surface : colorScheme.surfaceDim,
    extensions: [dark ? AppColors.dark : AppColors.light],
  );
}
