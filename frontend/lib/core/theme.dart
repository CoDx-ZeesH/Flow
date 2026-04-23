import 'package:flutter/material.dart';

// ─── SESSION STATE ENUM ───────────────────────────────────────────────────────
// Focus  → Blue  (normal deep work)
// Trough → Amber (fatigue warning)
// Drift  → Red   (critical — cognitive misalignment)
enum SessionState {
  focus,
  trough,
  drift,
}

class FlowTheme {
  FlowTheme._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LIGHT MODE — NBBS v2 Lite
  // Neutral base, strong borders, blue identity, amber/red for states
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // ─── BASE ────────────────────────────────────────────────────────────────
  static const Color bgLight       = Color(0xFFF4F5F7);
  static const Color surfaceLight  = Color(0xFFFFFFFF);
  static const Color elevatedLight = Color(0xFFFAFAFA);

  // ─── BORDERS ─────────────────────────────────────────────────────────────
  // Full black for interactive objects (buttons, inputs).
  // Soft gray for informational cards — prevents visual overload at density.
  static const Color borderLight     = Color(0xFF000000); // interactive
  static const Color borderSoftLight = Color(0xFFE5E7EB); // informational cards

  // ─── FOCUS STATE (PRIMARY) ───────────────────────────────────────────────
  static const Color focusLight      = Color(0xFF2563EB);
  static const Color focusSoftLight  = Color(0xFFDBEAFE);
  static const Color focusStrongLight= Color(0xFF1E40AF);

  // ─── FATIGUE STATE (TROUGH) ──────────────────────────────────────────────
  static const Color fatigueLight     = Color(0xFFF59E0B);
  static const Color fatigueSoftLight = Color(0xFFFEF3C7);

  // ─── DRIFT STATE (CRITICAL) ──────────────────────────────────────────────
  static const Color driftLight     = Color(0xFFEF4444);
  static const Color driftSoftLight = Color(0xFFFEE2E2);

  // ─── TEXT ────────────────────────────────────────────────────────────────
  static const Color text1Light = Color(0xFF111111);
  static const Color text2Light = Color(0xFF666666);
  static const Color text3Light = Color(0xFF9CA3AF);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DARK MODE — Yin–Yang System
  // Near-monochrome base, white borders for sharpness, color only for meaning
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // ─── BASE ────────────────────────────────────────────────────────────────
  static const Color bgDark       = Color(0xFF0B0B0C);
  static const Color surfaceDark  = Color(0xFF111113);
  static const Color elevatedDark = Color(0xFF18181B);

  // ─── BORDERS ─────────────────────────────────────────────────────────────
  static const Color borderDark     = Color(0xFFFFFFFF); // interactive — full white
  static const Color borderSoftDark = Color(0xFF27272A); // informational cards

  // ─── FOCUS STATE (PRIMARY) ───────────────────────────────────────────────
  static const Color focusDark     = Color(0xFF3B82F6);
  static const Color focusSoftDark = Color(0xFF1E3A8A);

  // ─── FATIGUE STATE (TROUGH) ──────────────────────────────────────────────
  static const Color fatigueDark     = Color(0xFFF59E0B);
  static const Color fatigueSoftDark = Color(0xFF78350F);

  // ─── DRIFT STATE (CRITICAL) ──────────────────────────────────────────────
  static const Color driftDark     = Color(0xFFEF4444);
  static const Color driftSoftDark = Color(0xFF7F1D1D);

  // ─── TEXT ────────────────────────────────────────────────────────────────
  static const Color text1Dark = Color(0xFFF4F4F5);
  static const Color text2Dark = Color(0xFFA1A1AA);
  static const Color text3Dark = Color(0xFF71717A);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SEMANTIC HELPERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Primary accent color for a given cognitive state.
  static Color stateColor(BuildContext context, SessionState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (state) {
      case SessionState.focus:
        return isDark ? focusDark : focusLight;
      case SessionState.trough:
        return isDark ? fatigueDark : fatigueLight;
      case SessionState.drift:
        return isDark ? driftDark : driftLight;
    }
  }

  /// Soft tint color for a given state (backgrounds, chips, fills).
  static Color stateSoftColor(BuildContext context, SessionState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (state) {
      case SessionState.focus:
        return isDark ? focusSoftDark : focusSoftLight;
      case SessionState.trough:
        return isDark ? fatigueSoftDark : fatigueSoftLight;
      case SessionState.drift:
        return isDark ? driftSoftDark : driftSoftLight;
    }
  }

  /// Full page background — shifts subtly on trough/drift to signal state.
  static Color pageBackground(BuildContext context, SessionState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (state) {
      case SessionState.focus:
        return isDark ? bgDark : bgLight;
      case SessionState.trough:
        return isDark ? fatigueSoftDark : fatigueSoftLight;
      case SessionState.drift:
        return isDark ? driftSoftDark : driftSoftLight;
    }
  }

  /// Ring track (background arc) for the FocusRing widget.
  static Color ringTrackColor(BuildContext context, SessionState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (state) {
      case SessionState.focus:
        return isDark ? borderSoftDark : borderSoftLight;
      case SessionState.trough:
        return isDark ? fatigueSoftDark : fatigueSoftLight;
      case SessionState.drift:
        return isDark ? driftSoftDark : driftSoftLight;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PAGE TRANSITIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const PageTransitionsTheme _fluidTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS:   FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux:   FadeUpwardsPageTransitionsBuilder(),
    },
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LIGHT THEME
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      primaryColor: focusLight,
      cardColor: surfaceLight,
      dividerColor: borderSoftLight,
      fontFamily: 'Inter',
      pageTransitionsTheme: _fluidTransitions,

      colorScheme: const ColorScheme.light(
        primary:            focusLight,
        primaryContainer:   focusSoftLight,
        secondary:          fatigueLight,
        secondaryContainer: fatigueSoftLight,
        error:              driftLight,
        errorContainer:     driftSoftLight,
        surface:            surfaceLight,
        onPrimary:          Colors.white,
        onSecondary:        Colors.white,
        onError:            Colors.white,
        onSurface:          text1Light,
      ),

      textTheme: const TextTheme(
        // ── Big numbers (DM Mono — telemetry, timers)
        displayLarge:  TextStyle(fontFamily: 'DM Mono', color: text1Light, fontWeight: FontWeight.w800, fontSize: 56, letterSpacing: -2.0),
        displayMedium: TextStyle(fontFamily: 'DM Mono', color: text1Light, fontWeight: FontWeight.w800, fontSize: 40, letterSpacing: -1.5),

        // ── Headings (Inter)
        headlineLarge:  TextStyle(color: text1Light, fontWeight: FontWeight.w700, fontSize: 24, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: text1Light, fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: -0.3),
        headlineSmall:  TextStyle(color: text1Light, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: -0.1),

        // ── Body (Inter)
        bodyLarge:  TextStyle(color: text1Light, fontSize: 15, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: text2Light, fontSize: 13, fontWeight: FontWeight.w400),
        bodySmall:  TextStyle(color: text3Light, fontSize: 11, fontWeight: FontWeight.w400),

        // ── Labels (DM Mono — badges, card labels, data readouts)
        labelLarge:  TextStyle(fontFamily: 'DM Mono', color: text2Light, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        labelMedium: TextStyle(fontFamily: 'DM Mono', color: text3Light, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0),
        labelSmall:  TextStyle(fontFamily: 'DM Mono', color: text3Light, fontSize: 9,  fontWeight: FontWeight.w500, letterSpacing: 0.8),
      ),

      // ── Informational cards: soft gray border (not overwhelming at density)
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderSoftLight, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Inputs: hard black border (interactive = obvious)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: focusLight, width: 2.5),
        ),
        hintStyle: const TextStyle(
          color: text3Light, fontSize: 14, fontFamily: 'Inter',
        ),
      ),

      // ── Buttons: hard black border, brutalist shape
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: focusLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: borderLight, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text buttons (secondary actions)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: focusLight,
          textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: borderSoftLight, thickness: 1, space: 8,
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DARK THEME
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: focusDark,
      cardColor: surfaceDark,
      dividerColor: borderSoftDark,
      fontFamily: 'Inter',
      pageTransitionsTheme: _fluidTransitions,

      colorScheme: const ColorScheme.dark(
        primary:            focusDark,
        primaryContainer:   focusSoftDark,
        secondary:          fatigueDark,
        secondaryContainer: fatigueSoftDark,
        error:              driftDark,
        errorContainer:     driftSoftDark,
        surface:            surfaceDark,
        onPrimary:          Colors.white,
        onSecondary:        Colors.white,
        onError:            Colors.white,
        onSurface:          text1Dark,
      ),

      textTheme: const TextTheme(
        // ── Big numbers (DM Mono)
        displayLarge:  TextStyle(fontFamily: 'DM Mono', color: text1Dark, fontWeight: FontWeight.w800, fontSize: 56, letterSpacing: -2.0),
        displayMedium: TextStyle(fontFamily: 'DM Mono', color: text1Dark, fontWeight: FontWeight.w800, fontSize: 40, letterSpacing: -1.5),

        // ── Headings (Inter)
        headlineLarge:  TextStyle(color: text1Dark, fontWeight: FontWeight.w700, fontSize: 24, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: text1Dark, fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: -0.3),
        headlineSmall:  TextStyle(color: text1Dark, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: -0.1),

        // ── Body (Inter)
        bodyLarge:  TextStyle(color: text1Dark, fontSize: 15, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: text2Dark, fontSize: 13, fontWeight: FontWeight.w400),
        bodySmall:  TextStyle(color: text3Dark, fontSize: 11, fontWeight: FontWeight.w400),

        // ── Labels (DM Mono)
        labelLarge:  TextStyle(fontFamily: 'DM Mono', color: text2Dark, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        labelMedium: TextStyle(fontFamily: 'DM Mono', color: text3Dark, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0),
        labelSmall:  TextStyle(fontFamily: 'DM Mono', color: text3Dark, fontSize: 9,  fontWeight: FontWeight.w500, letterSpacing: 0.8),
      ),

      // ── Informational cards: soft dark border
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderSoftDark, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Inputs: hard white border
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: focusDark, width: 2.5),
        ),
        hintStyle: const TextStyle(
          color: text3Dark, fontSize: 14, fontFamily: 'Inter',
        ),
      ),

      // ── Buttons: hard white border
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: focusDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: borderDark, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: focusDark,
          textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: borderSoftDark, thickness: 1, space: 8,
      ),
    );
  }
}