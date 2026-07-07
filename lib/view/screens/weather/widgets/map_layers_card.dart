import 'package:flutter/material.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/widgets/widgets.dart';

class MapLayersCard extends StatelessWidget {
  const MapLayersCard({super.key, required this.layerUrls});

  final Map<String, String> layerUrls;

  @override
  Widget build(BuildContext context) {
    if (layerUrls.isEmpty) return const SizedBox.shrink();

    return WeatherGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conditions map',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: WeatherTheme.onGlassPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Clouds, rain, temperature, and wind layers are available.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: WeatherTheme.onGlassSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: layerUrls.entries.map((entry) {
              return Tooltip(
                message: entry.value,
                child: Chip(
                  avatar: const Icon(
                    Icons.layers_rounded,
                    size: 18,
                    color: WeatherTheme.rainAccent,
                  ),
                  label: Text(
                    entry.key,
                    style: const TextStyle(
                      color: WeatherTheme.onGlassPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  backgroundColor:
                      WeatherTheme.glassInset.withValues(alpha: 0.46),
                  side: const BorderSide(color: WeatherTheme.glassStroke),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
