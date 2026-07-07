import 'package:flutter/material.dart';
import 'package:weather_test/data/model/weather_model.dart';
import 'package:weather_test/theme/weather_theme.dart';

class WeatherSummaryCard extends StatelessWidget {
  const WeatherSummaryCard({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            weather.cityName.isEmpty
                ? 'Current location'
                : '${weather.cityName}, ${weather.country}',
            style: textTheme.headlineSmall?.copyWith(
              color: WeatherTheme.onGlassPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _sentenceCase(weather.description),
            style: textTheme.bodyLarge?.copyWith(
              color: WeatherTheme.onGlassSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${weather.temperature.round()}°',
                  style: textTheme.displayLarge?.copyWith(
                    color: WeatherTheme.onGlassPrimary,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                  ),
                ),
              ),
              Image.network(
                'https://openweathermap.org/img/wn/${weather.icon}@4x.png',
                width: 96,
                height: 96,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.cloud_rounded,
                  size: 72,
                  color: WeatherTheme.primarySky,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _SecondaryWeatherDetail(
                label: 'Feels like',
                value: '${weather.feelsLike.round()}°',
                icon: Icons.thermostat_rounded,
              ),
              _SecondaryWeatherDetail(
                label: 'High',
                value: '${weather.tempMax.round()}°',
                icon: Icons.arrow_upward_rounded,
              ),
              _SecondaryWeatherDetail(
                label: 'Low',
                value: '${weather.tempMin.round()}°',
                icon: Icons.arrow_downward_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _sentenceCase(String value) {
    if (value.isEmpty) return 'Weather unavailable';
    return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
  }
}

class _SecondaryWeatherDetail extends StatelessWidget {
  const _SecondaryWeatherDetail({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: WeatherTheme.onGlassSecondary, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: WeatherTheme.onGlassSecondary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: WeatherTheme.onGlassPrimary,
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}
