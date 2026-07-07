import 'package:flutter/material.dart';
import 'package:weather_test/data/model/forecast_model.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/widgets/widgets.dart';

class WeatherForecastStrip extends StatelessWidget {
  const WeatherForecastStrip({super.key, required this.forecast});

  final WeatherForecast forecast;

  @override
  Widget build(BuildContext context) {
    if (forecast.days.isEmpty) {
      return const SizedBox.shrink();
    }

    final min = forecast.days
        .map((day) => day.minTemp)
        .reduce((value, element) => value < element ? value : element);
    final max = forecast.days
        .map((day) => day.maxTemp)
        .reduce((value, element) => value > element ? value : element);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '5-day outlook',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        ...forecast.days.map(
          (day) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ForecastRow(
              day: day,
              rangeMin: min,
              rangeMax: max,
            ),
          ),
        ),
      ],
    );
  }
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({
    required this.day,
    required this.rangeMin,
    required this.rangeMax,
  });

  final ForecastDay day;
  final double rangeMin;
  final double rangeMax;

  @override
  Widget build(BuildContext context) {
    return WeatherGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _weekday(day.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: WeatherTheme.onGlassPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  _shortDate(day.date),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: WeatherTheme.onGlassSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Image.network(
            'https://openweathermap.org/img/wn/${day.icon}@2x.png',
            width: 52,
            height: 52,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.cloud_rounded,
              size: 38,
              color: WeatherTheme.primarySky,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: WeatherTheme.onGlassPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                _TemperatureRangeBar(
                  minTemp: day.minTemp,
                  maxTemp: day.maxTemp,
                  rangeMin: rangeMin,
                  rangeMax: rangeMax,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'High ${day.maxTemp.round()}°',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: WeatherTheme.onGlassPrimary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Low ${day.minTemp.round()}°',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: WeatherTheme.onGlassSecondary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _weekday(DateTime date) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }

  String _shortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _TemperatureRangeBar extends StatelessWidget {
  const _TemperatureRangeBar({
    required this.minTemp,
    required this.maxTemp,
    required this.rangeMin,
    required this.rangeMax,
  });

  final double minTemp;
  final double maxTemp;
  final double rangeMin;
  final double rangeMax;

  @override
  Widget build(BuildContext context) {
    final total = (rangeMax - rangeMin).abs();
    final start = total == 0 ? 0.0 : ((minTemp - rangeMin) / total).clamp(0, 1);
    final width = total == 0 ? 1.0 : ((maxTemp - minTemp) / total).clamp(0, 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final left = barWidth * start;
        final activeWidth = (barWidth * width).clamp(18.0, barWidth);

        return Stack(
          key: const ValueKey('forecast-range-bar'),
          children: [
            Container(
              height: 7,
              decoration: BoxDecoration(
                color: WeatherTheme.glassInset.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(WeatherTheme.radiusSm),
              ),
            ),
            Positioned(
              left: left,
              child: Container(
                width: activeWidth,
                height: 7,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      WeatherTheme.rainAccent,
                      WeatherTheme.sunnyAccent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(WeatherTheme.radiusSm),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
