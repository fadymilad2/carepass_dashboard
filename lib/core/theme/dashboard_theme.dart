import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DColors {
  DColors._();

  static const primary = Color(0xFF0D7B6E);
  static const primaryLight = Color(0xFFE6F4F2);
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const sidebar = Color(0xFF0A6860);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF1A202C);
  static const textSecondary = Color(0xFF718096);
  static const textHint = Color(0xFFA0AEC0);
  static const success = Color(0xFF38A169);
  static const successLight = Color(0xFFE6F4ED);
  static const warning = Color(0xFFD69E2E);
  static const warningLight = Color(0xFFFEF3C7);
  static const error = Color(0xFFE53E3E);
  static const errorLight = Color(0xFFFEE2E2);
  static const info = Color(0xFF3182CE);
  static const infoLight = Color(0xFFEBF5FF);

  static const List<Color> chartColors = [
    Color(0xFF0D7B6E),
    Color(0xFF3182CE),
    Color(0xFF38A169),
    Color(0xFFD69E2E),
    Color(0xFFE53E3E),
    Color(0xFF805AD5),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF0D7B6E),
    Color(0xFF095C52),
  ];
}

class DTextStyles {
  DTextStyles._();

  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: DColors.textPrimary,
  );

  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: DColors.textPrimary,
  );

  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: DColors.textPrimary,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: DColors.textSecondary,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: DColors.textPrimary,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: DColors.textSecondary,
  );
}

class DDimens {
  DDimens._();

  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double radiusSM = 6.0;
  static const double radiusMD = 10.0;
  static const double radiusLG = 14.0;
  static const double sidebarW = 240.0;
  static const double topBarH = 60.0;
}

class DashboardTheme {
  DashboardTheme._();

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: DColors.primary,
      primary: DColors.primary,
      surface: DColors.surface,
    ),
    scaffoldBackgroundColor: DColors.background,
    fontFamily: GoogleFonts.inter().fontFamily,

    // Card
    cardTheme: CardThemeData(
      color: DColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DDimens.radiusLG),
        side: const BorderSide(color: DColors.border),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DDimens.radiusMD),
        borderSide: const BorderSide(color: DColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DDimens.radiusMD),
        borderSide: const BorderSide(color: DColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DDimens.radiusMD),
        borderSide: const BorderSide(color: DColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DDimens.radiusMD),
        borderSide: const BorderSide(color: DColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      hintStyle: DTextStyles.body.copyWith(color: DColors.textHint),
      prefixIconColor: DColors.textSecondary,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DDimens.radiusMD),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: DTextStyles.label.copyWith(color: Colors.white),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DColors.textSecondary,
        side: const BorderSide(color: DColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DDimens.radiusMD),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: DTextStyles.label,
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: DColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DDimens.radiusLG),
      ),
      elevation: 4,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: DColors.border,
      thickness: 1,
      space: 0,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return DColors.textHint;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return DColors.primary;
        }
        return DColors.border;
      }),
    ),

    // Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: DColors.textPrimary,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: DTextStyles.bodySmall.copyWith(color: Colors.white),
    ),
  );
}
