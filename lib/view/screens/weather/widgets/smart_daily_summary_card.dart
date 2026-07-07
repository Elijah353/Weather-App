import 'package:flutter/material.dart';
import 'package:weather_test/data/model/forecast_model.dart';
import 'package:weather_test/data/model/weather_model.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/widgets/widgets.dart';

class SmartDailySummaryCard extends StatelessWidget {
  const SmartDailySummaryCard({
    super.key,
    required this.weather,
    required this.forecast,
  });

  final Weather weather;
  final WeatherForecast? forecast;

  @override
  Widget build(BuildContext context) {
    final summary = _summary();
    final guidance = _guidance();

    return WeatherGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: WeatherTheme.onGlassPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            guidance,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WeatherTheme.onGlassSecondary,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }

  String _summary() {
    final condition = weather.description.isEmpty
        ? weather.mainCondition.toLowerCase()
        : weather.description.toLowerCase();
    final rainChance = _maxRainChance();

    if (rainChance >= 0.35 || condition.contains('rain')) {
      return 'Light rain is likely at times, with temperatures near '
          '${weather.temperature.round()}\u00B0.';
    }

    if (condition.contains('clear')) {
      return 'Clear conditions are expected, with temperatures near '
          '${weather.temperature.round()}\u00B0.';
    }

    return '${_sentenceCase(condition)} conditions are expected, with '
        'temperatures near ${weather.temperature.round()}\u00B0.';
  }

  String _guidance() {
    final feelsDifference = weather.feelsLike - weather.temperature;
    final notes = <String>[];

    if (feelsDifference >= 2) {
      notes.add('It feels warmer than the thermometer suggests');
    } else if (feelsDifference <= -2) {
      notes.add('Wind may make it feel cooler than the thermometer suggests');
    }

    if (weather.humidity >= 75) {
      notes.add('humidity is high');
    }

    if (weather.windSpeed >= 7) {
      notes.add('expect a noticeable breeze');
    }

    if (_maxRainChance() >= 0.35) {
      notes.add('keep rain gear close');
    }

    if (notes.isEmpty) {
      return 'Good conditions for regular outdoor plans.';
    }

    return '${_sentenceCase(notes.join(', '))}.';
  }

  double _maxRainChance() {
    final hourly = forecast?.hourly ?? const <ForecastHour>[];
    if (hourly.isEmpty) return 0;

    return hourly
        .map((hour) => hour.precipitationChance)
        .reduce((a, b) => a > b ? a : b);
  }

  String _sentenceCase(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
