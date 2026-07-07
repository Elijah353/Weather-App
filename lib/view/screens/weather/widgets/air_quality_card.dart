import 'package:flutter/material.dart';
import 'package:weather_test/data/model/air_quality_model.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/widgets/widgets.dart';

class AirQualityCard extends StatelessWidget {
  const AirQualityCard({super.key, required this.airQuality});

  final AirQuality airQuality;

  @override
  Widget build(BuildContext context) {
    final color = _aqiColor(airQuality.index);

    return WeatherGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(WeatherTheme.radiusMd),
                  border: Border.all(color: color.withValues(alpha: 0.28)),
                ),
                child: Icon(Icons.air_rounded, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Air Quality',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: WeatherTheme.onGlassPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      airQuality.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                'AQI ${airQuality.index}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: WeatherTheme.onGlassPrimary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Pollutant(label: 'PM2.5', value: airQuality.pm25),
              _Pollutant(label: 'PM10', value: airQuality.pm10),
              _Pollutant(label: 'Ozone', value: airQuality.ozone),
              _Pollutant(label: 'NO2', value: airQuality.nitrogenDioxide),
            ],
          ),
        ],
      ),
    );
  }

  Color _aqiColor(int index) {
    return switch (index) {
      1 => WeatherTheme.success,
      2 => WeatherTheme.primarySky,
      3 => WeatherTheme.sunnyAccent,
      4 => Colors.deepOrange,
      5 => WeatherTheme.danger,
      _ => WeatherTheme.onGlassSecondary,
    };
  }
}

class _Pollutant extends StatelessWidget {
  const _Pollutant({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: WeatherTheme.glassInset.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(WeatherTheme.radiusSm),
        border: Border.all(color: WeatherTheme.glassStroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: WeatherTheme.onGlassSecondary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: WeatherTheme.onGlassPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}
