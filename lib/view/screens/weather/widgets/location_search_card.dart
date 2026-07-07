import 'package:flutter/material.dart';
import 'package:weather_test/data/model/location_model.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/widgets/widgets.dart';

class LocationSearchCard extends StatefulWidget {
  const LocationSearchCard({
    super.key,
    required this.results,
    required this.isSearching,
    required this.onSearch,
    required this.onSelect,
    this.savedLocations = const [],
    this.onSave,
    this.onRemoveSaved,
  });

  final List<WeatherLocation> results;
  final List<WeatherLocation> savedLocations;
  final bool isSearching;
  final ValueChanged<String> onSearch;
  final ValueChanged<WeatherLocation> onSelect;
  final ValueChanged<WeatherLocation>? onSave;
  final ValueChanged<WeatherLocation>? onRemoveSaved;

  @override
  State<LocationSearchCard> createState() => _LocationSearchCardState();
}

class _LocationSearchCardState extends State<LocationSearchCard> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WeatherGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            style: const TextStyle(
              color: WeatherTheme.onGlassPrimary,
              fontWeight: FontWeight.w700,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: _submit,
            decoration: InputDecoration(
              hintText: 'Search city',
              hintStyle: const TextStyle(color: WeatherTheme.onGlassMuted),
              prefixIconColor: WeatherTheme.onGlassSecondary,
              suffixIconColor: WeatherTheme.onGlassPrimary,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: widget.isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Search',
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: () => _submit(_controller.text),
                    ),
              filled: true,
              fillColor: WeatherTheme.glassInset.withValues(alpha: 0.46),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(WeatherTheme.radiusMd),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(WeatherTheme.radiusMd),
                borderSide: const BorderSide(color: WeatherTheme.glassStroke),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(WeatherTheme.radiusMd),
                borderSide: const BorderSide(color: WeatherTheme.rainAccent),
              ),
            ),
          ),
          if (widget.results.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...widget.results.map(
              (location) => Material(
                color: Colors.transparent,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.location_on_rounded,
                    color: WeatherTheme.rainAccent,
                  ),
                  title: Text(
                    location.displayName,
                    style: const TextStyle(
                      color: WeatherTheme.onGlassPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: 'Save ${location.name}',
                    icon: const Icon(
                      Icons.bookmark_add_rounded,
                      color: WeatherTheme.sunnyAccent,
                    ),
                    onPressed: widget.onSave == null
                        ? null
                        : () => widget.onSave!(location),
                  ),
                  onTap: () => widget.onSelect(location),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _submit(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    widget.onSearch(query);
  }
}
