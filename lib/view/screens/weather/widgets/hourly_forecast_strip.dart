import 'package:flutter/material.dart';
import 'package:weather_test/data/model/forecast_model.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/widgets/widgets.dart';

class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({super.key, required this.hourly});

  final List<ForecastHour> hourly;

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    return WeatherGlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next 24 hours',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: WeatherTheme.onGlassPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: hourly
                  .map(
                    (hour) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _HourlyTile(hour: hour),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyTile extends StatelessWidget {
  const _HourlyTile({required this.hour});

  final ForecastHour hour;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.all(12),
      decoration: WeatherTheme.insetGlassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _time(hour.time),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: WeatherTheme.onGlassSecondary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Image.network(
            'https://openweathermap.org/img/wn/${hour.icon}@2x.png',
            width: 42,
            height: 42,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.cloud_rounded,
              size: 34,
              color: WeatherTheme.rainAccent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${hour.temperature.round()}\u00B0',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: WeatherTheme.onGlassPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            hour.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: WeatherTheme.onGlassSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.water_drop_rounded,
                size: 15,
                color: WeatherTheme.rainAccent,
              ),
              const SizedBox(width: 4),
              Text(
                '${(hour.precipitationChance * 100).round()}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: WeatherTheme.onGlassPrimary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _time(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    return '$hour:00';
  }
}
