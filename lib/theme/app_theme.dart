import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the job matching application.
class AppTheme {
  AppTheme._();

  // Color Specifications - Updated with Green/Amber Theme
  static const Color primary = Color(
    0xFF4CAF50,
  ); // Green primary color for actions and branding
  static const Color secondary = Color(
    0xFFFFC107,
  ); // Amber secondary color for supporting elements and accents
  static const Color successGreatMatch = Color(
    0xFF4CAF50,
  ); // Match tier green for 85-100% compatibility
  static const Color infoGoodMatch = Color(
    0xFF2196F3,
  ); // Match tier blue for 70-84% compatibility
  static const Color warningOkayMatch = Color(
    0xFFFFC107,
  ); // Match tier amber for 50-69% compatibility
  static const Color neutralLowMatch = Color(
    0xFF6B7280,
  ); // Match tier grey for <50% compatibility
  static const Color backgroundLight = Color(
    0xFFF8FAFC,
  ); // Clean background that reduces eye strain
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // Card and modal backgrounds with pure white
  static const Color textPrimary = Color(
    0xFF1E293B,
  ); // High contrast text for excellent mobile readability
  static const Color textSecondary = Color(
    0xFF475569,
  ); // Supporting text color that maintains hierarchy

  // Dark theme colors
  static const Color primaryDark = Color(0xFF66BB6A);
  static const Color secondaryDark = Color(0xFFFFD54F);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Additional colors for comprehensive theming
  static const Color error = Color(0xFFDC2626);
  static const Color errorDark = Color(0xFFEF4444);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onSurface = Color(0xFF1E293B);
  static const Color onSurfaceDark = Color(0xFFF1F5F9);
  static const Color onError = Color(0xFFFFFFFF);

  // Border and shadow colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowColorDark = Color(0x1AFFFFFF);

  /// Light theme optimized for mobile job matching
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primary.withValues(alpha: 0.1),
      onPrimaryContainer: primary,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondary.withValues(alpha: 0.1),
      onSecondaryContainer: secondary,
      tertiary: infoGoodMatch,
      onTertiary: onPrimary,
      tertiaryContainer: infoGoodMatch.withValues(alpha: 0.1),
      onTertiaryContainer: infoGoodMatch,
      error: error,
      onError: onError,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: textSecondary,
      outline: borderLight,
      outlineVariant: borderLight.withValues(alpha: 0.5),
      shadow: shadowColor,
      scrim: shadowColor,
      inverseSurface: surfaceDark,
      onInverseSurface: onSurfaceDark,
      inversePrimary: primaryDark,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: surface,
    dividerColor: borderLight,

    // AppBar theme for professional confidence
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 2.0,
      shadowColor: shadowColor,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 24),
      actionsIconTheme: const IconThemeData(color: textPrimary, size: 24),
    ),

    // Card theme with contextual elevation
    cardTheme: CardThemeData(
      color: surface,
      elevation: 2.0,
      shadowColor: shadowColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom navigation for mobile-first navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
    ),

    // Contextual floating actions
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 4.0,
      focusElevation: 6.0,
      hoverElevation: 6.0,
      highlightElevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),

    // Button themes with micro-interaction feedback
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimary,
        backgroundColor: primary,
        elevation: 2.0,
        shadowColor: shadowColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Typography with Inter font family
    textTheme: _buildTextTheme(isLight: true),

    // Input decoration for form elements
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surface,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: borderLight, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: borderLight, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: error, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textSecondary.withValues(alpha: 0.7),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.inter(
        color: error,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary.withValues(alpha: 0.3);
        }
        return textSecondary.withValues(alpha: 0.3);
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimary),
      side: const BorderSide(color: borderLight, width: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return textSecondary;
      }),
    ),

    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: borderLight,
      circularTrackColor: borderLight,
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: primary,
      thumbColor: primary,
      overlayColor: primary.withValues(alpha: 0.2),
      inactiveTrackColor: borderLight,
      trackHeight: 4.0,
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: primary,
      unselectedLabelColor: textSecondary,
      indicatorColor: primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
    ),

    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: GoogleFonts.inter(
        color: surface,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // SnackBar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: GoogleFonts.inter(
        color: surface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4.0,
    ),

    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: secondary.withValues(alpha: 0.1),
      selectedColor: primary.withValues(alpha: 0.1),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      elevation: 8.0,
      shadowColor: shadowColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      elevation: 8.0,
      modalElevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
    ),
  );

  /// Dark theme optimized for mobile job matching
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: onPrimary,
      primaryContainer: primaryDark.withValues(alpha: 0.2),
      onPrimaryContainer: primaryDark,
      secondary: secondaryDark,
      onSecondary: onSecondary,
      secondaryContainer: secondaryDark.withValues(alpha: 0.2),
      onSecondaryContainer: secondaryDark,
      tertiary: infoGoodMatch,
      onTertiary: onPrimary,
      tertiaryContainer: infoGoodMatch.withValues(alpha: 0.2),
      onTertiaryContainer: infoGoodMatch,
      error: errorDark,
      onError: onError,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      onSurfaceVariant: textSecondaryDark,
      outline: borderDark,
      outlineVariant: borderDark.withValues(alpha: 0.5),
      shadow: shadowColorDark,
      scrim: shadowColorDark,
      inverseSurface: surface,
      onInverseSurface: onSurface,
      inversePrimary: primary,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: surfaceDark,
    dividerColor: borderDark,

    // AppBar theme for dark mode
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      elevation: 2.0,
      shadowColor: shadowColorDark,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: textPrimaryDark, size: 24),
      actionsIconTheme: const IconThemeData(color: textPrimaryDark, size: 24),
    ),

    // Card theme for dark mode
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 2.0,
      shadowColor: shadowColorDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom navigation for dark mode
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryDark,
      unselectedItemColor: textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
    ),

    // Floating action button for dark mode
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryDark,
      foregroundColor: onPrimary,
      elevation: 4.0,
      focusElevation: 6.0,
      hoverElevation: 6.0,
      highlightElevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),

    // Button themes for dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimary,
        backgroundColor: primaryDark,
        elevation: 2.0,
        shadowColor: shadowColorDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: primaryDark, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Typography for dark mode
    textTheme: _buildTextTheme(isLight: false),

    // Input decoration for dark mode
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceDark,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: borderDark, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: borderDark, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryDark, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorDark, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorDark, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondaryDark,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textSecondaryDark.withValues(alpha: 0.7),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.inter(
        color: errorDark,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Additional theme configurations for dark mode
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textSecondaryDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark.withValues(alpha: 0.3);
        }
        return textSecondaryDark.withValues(alpha: 0.3);
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimary),
      side: const BorderSide(color: borderDark, width: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textSecondaryDark;
      }),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryDark,
      linearTrackColor: borderDark,
      circularTrackColor: borderDark,
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: primaryDark,
      thumbColor: primaryDark,
      overlayColor: primaryDark.withValues(alpha: 0.2),
      inactiveTrackColor: borderDark,
      trackHeight: 4.0,
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: primaryDark,
      unselectedLabelColor: textSecondaryDark,
      indicatorColor: primaryDark,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimaryDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: GoogleFonts.inter(
        color: backgroundDark,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryDark,
      contentTextStyle: GoogleFonts.inter(
        color: backgroundDark,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: primaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4.0,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: secondaryDark.withValues(alpha: 0.2),
      selectedColor: primaryDark.withValues(alpha: 0.2),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPrimaryDark,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: surfaceDark,
      elevation: 8.0,
      shadowColor: shadowColorDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondaryDark,
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceDark,
      elevation: 8.0,
      modalElevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
    ),
  );

  /// Helper method to build text theme with Inter font family
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHigh = isLight ? textPrimary : textPrimaryDark;
    final Color textMedium = isLight ? textSecondary : textSecondaryDark;
    final Color textDisabled =
        isLight
            ? textSecondary.withValues(alpha: 0.6)
            : textSecondaryDark.withValues(alpha: 0.6);

    return TextTheme(
      // Display styles for large headings
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: textHigh,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: textHigh,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles for section headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles for job titles and important content
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles for job descriptions and content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textHigh,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textHigh,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMedium,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles for buttons and small UI elements
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHigh,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMedium,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textDisabled,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Match tier colors for job compatibility indicators
  static Color getMatchTierColor(double matchPercentage) {
    if (matchPercentage >= 85) {
      return successGreatMatch; // Great match (85-100%)
    } else if (matchPercentage >= 70) {
      return infoGoodMatch; // Good match (70-84%)
    } else if (matchPercentage >= 50) {
      return warningOkayMatch; // Okay match (50-69%)
    } else {
      return neutralLowMatch; // Low match (<50%)
    }
  }

  /// Get match tier text based on percentage
  static String getMatchTierText(double matchPercentage) {
    if (matchPercentage >= 85) {
      return 'Great Match';
    } else if (matchPercentage >= 70) {
      return 'Good Match';
    } else if (matchPercentage >= 50) {
      return 'Okay Match';
    } else {
      return 'Low Match';
    }
  }

  /// Generate AI-powered match reason based on user profile and job requirements
  static String generateMatchReason({
    required Map<String, dynamic> jobData,
    required Map<String, dynamic> userProfile,
  }) {
    final double matchPercentage =
        (jobData['matchPercentage'] as num?)?.toDouble() ?? 0.0;
    final String jobTitle = jobData['title'] as String? ?? '';
    final List<String> jobSkills =
        (jobData['skills'] as List<dynamic>?)?.cast<String>() ?? [];
    final String jobLocation = jobData['location'] as String? ?? '';
    final String workMode = jobData['workMode'] as String? ?? '';
    final String experience = jobData['experience'] as String? ?? '';

    // Mock user profile - in real app this would come from actual user data
    final List<String> userSkills =
        userProfile['skills'] as List<String>? ??
        ['Flutter', 'Dart', 'Firebase', 'Mobile Development'];
    final String userLocation = userProfile['location'] as String? ?? 'Mumbai';
    final String userExperience =
        userProfile['experience'] as String? ?? '4+ years';
    final String userPreferredWorkMode =
        userProfile['workMode'] as String? ?? 'Hybrid';

    // Generate contextual match reasons based on match percentage tiers
    if (matchPercentage >= 85) {
      // Great match - highlight strongest alignment
      final List<String> matchingSkills =
          jobSkills
              .where(
                (skill) => userSkills.any(
                  (userSkill) =>
                      userSkill.toLowerCase().contains(skill.toLowerCase()) ||
                      skill.toLowerCase().contains(userSkill.toLowerCase()),
                ),
              )
              .toList();

      if (matchingSkills.isNotEmpty) {
        return 'Perfect ${matchingSkills.first} expertise match with $userExperience experience and $userLocation location preference';
      }
      return 'Excellent alignment with your $userExperience experience and $userPreferredWorkMode work preference';
    } else if (matchPercentage >= 70) {
      // Good match - balanced strengths
      if (workMode.toLowerCase() == userPreferredWorkMode.toLowerCase()) {
        return 'Strong skill alignment with your background and preferred $workMode work setup';
      }
      return 'Good skills and experience match with ${jobLocation.split(',').first} location opportunity';
    } else if (matchPercentage >= 50) {
      // Okay match - some overlap with growth potential
      return 'Moderate fit with transferable skills and potential for professional growth in $jobTitle role';
    } else {
      // Low match - be honest about misalignment
      if (experience.contains('1-3') && userExperience.contains('4+')) {
        return 'Entry-level role below your $userExperience experience and different tech stack focus';
      }
      return 'Limited alignment with current profile, but could offer new experience in ${jobSkills.take(2).join(' and ')}';
    }
  }

  /// Generate specific match reasons for demo purposes
  static String getSmartMatchReason(Map<String, dynamic> jobData) {
    final double matchPercentage =
        (jobData['matchPercentage'] as num?)?.toDouble() ?? 0.0;
    final String jobTitle = jobData['title'] as String? ?? '';
    final String location = jobData['location'] as String? ?? '';
    final String workMode = jobData['workMode'] as String? ?? '';

    // Smart contextual reasons based on job analysis
    switch (jobData['id'] as int?) {
      case 1: // Flutter Developer
        return 'Perfect Flutter expertise match with 4+ years experience and Mumbai location preference';
      case 2: // Product Designer
        return 'Strong design skills align with UI/UX background and remote work preference';
      case 3: // Data Scientist
        return 'Python and analytics experience overlap, but different from core mobile development focus';
      case 4: // Frontend Developer
        return 'Entry-level role below your 4+ years experience and different tech stack focus';
      case 5: // DevOps Engineer
        return 'Excellent match with cloud infrastructure skills and preferred remote work setup';
      default:
        if (matchPercentage >= 85) {
          return 'Exceptional alignment with your skills, experience, and $workMode work preference';
        } else if (matchPercentage >= 70) {
          return 'Strong match for your profile with good location fit in ${location.split(',').first}';
        } else if (matchPercentage >= 50) {
          return 'Decent opportunity to expand skills in $jobTitle with growth potential';
        } else {
          return 'Limited fit but could provide exposure to new technologies and methodologies';
        }
    }
  }
}
