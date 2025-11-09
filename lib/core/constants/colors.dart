import 'package:flutter/material.dart';

/// App color constants
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);

  // Accent Colors
  static const Color accent = Color(0xFF10B981); // Green
  static const Color accentDark = Color(0xFF059669);
  static const Color accentLight = Color(0xFF34D399);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Colors - Light Theme
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color onBackground = Color(0xFF111827);
  static const Color onSurface = Color(0xFF1F2937);

  // Neutral Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceVariantDark = Color(0xFF374151);
  static const Color onBackgroundDark = Color(0xFFF9FAFB);
  static const Color onSurfaceDark = Color(0xFFE5E7EB);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);
  static const Color textDisabledDark = Color(0xFF6B7280);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Lock Screen Colors
  static const Color lockScreenBackground = Color(0xFF1F2937);
  static const Color lockScreenSurface = Color(0xFF374151);
  static const Color lockScreenAccent = Color(0xFF818CF8);

  // Gradient Colors
  static const List<Color> gradientPrimary = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> gradientAccent = [
    Color(0xFF10B981),
    Color(0xFF3B82F6),
  ];

  static const List<Color> gradientDanger = [
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
  ];

  // Special Colors
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);
  static const Color shimmerBaseDark = Color(0xFF374151);
  static const Color shimmerHighlightDark = Color(0xFF4B5563);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];
}
