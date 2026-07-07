import 'package:flutter/material.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/widgets/widgets.dart';

class WeatherErrorView extends StatelessWidget {
  const WeatherErrorView({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WeatherGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: WeatherTheme.danger.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(WeatherTheme.radiusLg),
              border: Border.all(
                color: WeatherTheme.danger.withValues(alpha: 0.26),
              ),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: WeatherTheme.danger,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Weather unavailable',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: WeatherTheme.onGlassPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check location access, service availability, or your connection.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WeatherTheme.onGlassSecondary,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
