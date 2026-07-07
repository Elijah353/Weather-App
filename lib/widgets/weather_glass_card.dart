import 'package:flutter/material.dart';
import 'package:weather_test/theme/weather_theme.dart';

class WeatherGlassCard extends StatelessWidget {
  const WeatherGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: WeatherTheme.glassDecoration(),
      child: child,
    );
  }
}
