import 'package:flutter/material.dart';
import 'package:weather_test/data/model/weather_model.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/view/screens/weather/widgets/weather_metric_tile.dart';

class WeatherMetricGrid extends StatelessWidget {
  const WeatherMetricGrid({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _WeatherMetric(
        icon: Icons.water_drop_rounded,
        label: 'Humidity',
        value: '${weather.humidity}%',
        accent: WeatherTheme.rainAccent,
        progress: weather.humidity.clamp(0, 100) / 100,
        progressKey: const ValueKey('humidity-progress-bar'),
      ),
      _WeatherMetric(
        icon: Icons.air_rounded,
        label: 'Wind',
        value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
        accent: WeatherTheme.rainAccent,
        visual: WeatherMetricVisual.wind,
        visualKey: const ValueKey('wind-direction-gauge'),
      ),
      _WeatherMetric(
        icon: Icons.speed_rounded,
        label: 'Pressure',
        value: '${weather.pressure.round()} hPa',
        accent: WeatherTheme.onGlassSecondary,
        visual: WeatherMetricVisual.pressure,
        visualKey: const ValueKey('pressure-arc-gauge'),
      ),
      _WeatherMetric(
        icon: Icons.visibility_rounded,
        label: 'Visibility',
        value: _formatVisibility(weather.visibility),
        accent: WeatherTheme.rainAccent,
        visual: WeatherMetricVisual.visibility,
        visualKey: const ValueKey('visibility-range-visual'),
      ),
      _WeatherMetric(
        icon: Icons.wb_twilight_rounded,
        label: 'Sunrise',
        value: _formatTime(weather.sunrise),
        accent: WeatherTheme.sunnyAccent,
        visual: WeatherMetricVisual.sunrise,
        visualKey: const ValueKey('sunrise-horizon-visual'),
      ),
      _WeatherMetric(
        icon: Icons.nightlight_round,
        label: 'Sunset',
        value: _formatTime(weather.sunset),
        accent: WeatherTheme.onGlassMuted,
        visual: WeatherMetricVisual.sunset,
        visualKey: const ValueKey('sunset-horizon-visual'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final tileWidth = (availableWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: metrics.map((metric) {
            return SizedBox(
              width: tileWidth,
              child: WeatherMetricTile(
                icon: metric.icon,
                label: metric.label,
                value: metric.value,
                accent: metric.accent,
                progress: metric.progress,
                progressKey: metric.progressKey,
                visual: metric.visual,
                visualKey: metric.visualKey,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatVisibility(int meters) {
    if (meters <= 0) return '--';
    final kilometers = meters / 1000;
    return '${kilometers.toStringAsFixed(1)} km';
  }
}

class _WeatherMetric {
  const _WeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.progress,
    this.progressKey,
    this.visual = WeatherMetricVisual.none,
    this.visualKey,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final double? progress;
  final Key? progressKey;
  final WeatherMetricVisual visual;
  final Key? visualKey;
}
