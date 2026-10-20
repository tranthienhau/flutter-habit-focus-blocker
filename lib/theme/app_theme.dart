import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from design/DESIGN.md (palette P58 aubergine workspace, Lato / Gloock).
class AppColors {
  static const background = Color(0xFFFCF4FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF7EEF7);
  static const accent = Color(0xFF4A154B);
  static const accentPressed = Color(0xFF3F1240);
  static const accentTint = Color(0xFFE6DEE6);
  static const chip = Color(0xFFF3EAF3);
  static const support = Color(0xFFECB22E);
  static const textPrimary = Color(0xFF1E0C1F);
  static const textSecondary = Color(0xFF5E4A5F);
  static const textTertiary = Color(0xFF8F7D90);
  static const border = Color(0xFFEADCEA);
  static const success = Color(0xFF16A34A);
  static const successTint = Color(0xFFE3F5E9);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);

  /// Soft 2-stop hero gradient used on streak card, paywall hero, live session and shield.
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A154B), Color(0xFF6B2A5E)],
  );

  static const progressGradient = LinearGradient(colors: [Color(0xFF4A154B), Color(0xFFECB22E)]);
}

class AppRadius {
  static const card = 20.0;
  static const control = 14.0;
  static const input = 12.0;
}

class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x0A1E0C1F), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F1E0C1F), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

class AppText {
  static TextStyle display({double size = 32, Color color = AppColors.textPrimary}) =>
      GoogleFonts.gloock(fontSize: size, color: color, letterSpacing: -0.02 * size, height: 1.1);
  static TextStyle title({Color color = AppColors.textPrimary, double size = 20}) =>
      GoogleFonts.lato(fontSize: size, fontWeight: FontWeight.w700, color: color);
  static TextStyle body({Color color = AppColors.textPrimary}) =>
      GoogleFonts.lato(fontSize: 16, color: color, height: 1.45);
  static TextStyle label({Color color = AppColors.textPrimary, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.lato(fontSize: 14, fontWeight: weight, color: color);
  static TextStyle caption({Color color = AppColors.textSecondary}) =>
      GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w400, color: color);
  static TextStyle overline({Color color = AppColors.textSecondary}) =>
      GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.1);
  static TextStyle numerals({double size = 14, Color color = AppColors.textPrimary, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.lato(fontSize: size, fontWeight: weight, color: color, fontFeatures: const [FontFeature.tabularFigures()]);
}

/// Fetches every Lato weight and Gloock up front so the first frame never uses a fallback font.
Future<void> preloadFonts() => GoogleFonts.pendingFonts([
      GoogleFonts.gloock(),
      for (final w in [FontWeight.w400, FontWeight.w700, FontWeight.w900]) GoogleFonts.lato(fontWeight: w),
    ]);

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent, primary: AppColors.accent, surface: AppColors.surface),
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
    );
    return base.copyWith(
      textTheme: GoogleFonts.latoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.accentTint),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: GoogleFonts.lato(color: AppColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.accent, width: 2)),
      ),
    );
  }
}
