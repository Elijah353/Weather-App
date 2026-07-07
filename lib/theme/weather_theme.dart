import 'package:flutter/material.dart';

class WeatherTheme {
  const WeatherTheme._();

  static const Color primarySky = Color(0xFF1769E0);
  static const Color deepSky = Color(0xFF062B55);
  static const Color twilight = Color(0xFF101827);
  static const Color cloud = Color(0xFFF5F8FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color glassSurface = Color(0xFF082A46);
  static const Color glassInset = Color(0xFF123C5F);
  static const Color glassStroke = Color(0x4DF8FBFF);
  static const Color onGlassPrimary = Color(0xFFF8FBFF);
  static const Color onGlassSecondary = Color(0xFFC7D7EA);
  static const Color onGlassMuted = Color(0xFF9FB5CE);
  static const Color sunnyAccent = Color(0xFFFFB84D);
  static const Color rainAccent = Color(0xFF38BDF8);
  static const Color success = Color(0xFF15803D);
  static const Color danger = Color(0xFFDC2626);

  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 30;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySky,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: cloud,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          fixedSize: const Size.square(44),
          foregroundColor: Colors.white,
          backgroundColor: Colors.white24,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: primarySky.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? primarySky : textSecondary,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primarySky : textSecondary,
          );
        }),
      ),
    );
  }

  static const LinearGradient screenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B4EA2),
      Color(0xFF1677E8),
      Color(0xFF79D6F2),
    ],
  );

  static const LinearGradient sunnyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1769E0),
      Color(0xFF3BA3F5),
      Color(0xFFFFC85C),
    ],
  );

  static const LinearGradient rainyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A2238),
      Color(0xFF14517B),
      Color(0xFF38BDF8),
    ],
  );

  static const LinearGradient cloudyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF334155),
      Color(0xFF2563A6),
      Color(0xFF94A3B8),
    ],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF07111F),
      Color(0xFF102A4C),
      Color(0xFF4338CA),
    ],
  );

  static LinearGradient gradientForCondition(String? condition) {
    final value = condition?.toLowerCase() ?? '';

    if (value.contains('night')) return nightGradient;
    if (value.contains('rain') ||
        value.contains('storm') ||
        value.contains('drizzle') ||
        value.contains('thunder')) {
      return rainyGradient;
    }
    if (value.contains('clear') || value.contains('sun')) {
      return sunnyGradient;
    }
    if (value.contains('cloud') ||
        value.contains('mist') ||
        value.contains('fog') ||
        value.contains('haze')) {
      return cloudyGradient;
    }

    return screenGradient;
  }

  static BoxDecoration glassDecoration({
    double radius = radiusLg,
    Color background = glassSurface,
  }) {
    return BoxDecoration(
      color: background.withValues(alpha: 0.26),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: twilight.withValues(alpha: 0.16),
          blurRadius: 24,
          offset: const Offset(0, 16),
        ),
      ],
    );
  }

  static BoxDecoration insetGlassDecoration({
    double radius = radiusMd,
    Color background = glassInset,
  }) {
    return BoxDecoration(
      color: background.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: glassStroke.withValues(alpha: 0.62)),
    );
  }
}
