import 'package:flutter/material.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/widgets/widgets.dart';

class WeatherLoadingView extends StatelessWidget {
  const WeatherLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const WeatherGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              color: WeatherTheme.primarySky,
              strokeWidth: 4,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Checking your local weather',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: WeatherTheme.onGlassPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
