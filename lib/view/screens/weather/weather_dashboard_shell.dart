import 'package:flutter/material.dart';
import 'package:weather_test/data/model/forecast_model.dart';
import 'package:weather_test/data/model/location_model.dart';
import 'package:weather_test/data/model/weather_dashboard_model.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/view/screens/weather/widgets/air_quality_card.dart';
import 'package:weather_test/view/screens/weather/widgets/hourly_forecast_strip.dart';
import 'package:weather_test/view/screens/weather/widgets/location_search_card.dart';
import 'package:weather_test/view/screens/weather/widgets/map_layers_card.dart';
import 'package:weather_test/view/screens/weather/widgets/smart_daily_summary_card.dart';
import 'package:weather_test/view/screens/weather/widgets/weather_error_view.dart';
import 'package:weather_test/view/screens/weather/widgets/weather_forecast_strip.dart';
import 'package:weather_test/view/screens/weather/widgets/weather_loading_view.dart';
import 'package:weather_test/view/screens/weather/widgets/weather_metric_grid.dart';
import 'package:weather_test/view/screens/weather/widgets/weather_summary_card.dart';
import 'package:weather_test/widgets/widgets.dart';

class WeatherDashboardShell extends StatefulWidget {
  const WeatherDashboardShell({
    super.key,
    required this.dashboard,
    required this.isLoading,
    required this.isSearching,
    required this.searchResults,
    this.savedLocations = const [],
    this.savedDashboards = const {},
    required this.mapLayerUrls,
    required this.onRefresh,
    required this.onSearch,
    required this.onSelectLocation,
    this.onSelectCurrentLocation,
    this.onSwipeLocation,
    this.onSaveLocation,
    this.onRemoveSavedLocation,
  });

  final WeatherDashboard? dashboard;
  final bool isLoading;
  final bool isSearching;
  final List<WeatherLocation> searchResults;
  final List<WeatherLocation> savedLocations;
  final Map<String, WeatherDashboard> savedDashboards;
  final Map<String, String> mapLayerUrls;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSearch;
  final ValueChanged<WeatherLocation> onSelectLocation;
  final Future<void> Function()? onSelectCurrentLocation;
  final ValueChanged<WeatherLocation>? onSwipeLocation;
  final ValueChanged<WeatherLocation>? onSaveLocation;
  final ValueChanged<WeatherLocation>? onRemoveSavedLocation;

  @override
  State<WeatherDashboardShell> createState() => _WeatherDashboardShellState();
}

class _WeatherDashboardShellState extends State<WeatherDashboardShell> {
  bool _isSearchVisible = false;
  bool _suppressNextCurrentPageSelection = false;
  int _locationCarouselIndex = 0;
  late final PageController _locationPageController;

  @override
  void initState() {
    super.initState();
    _locationPageController = PageController();
  }

  @override
  void dispose() {
    _locationPageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WeatherDashboardShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final carouselLength = widget.savedLocations.length + 1;
    if (_locationCarouselIndex >= carouselLength) {
      _locationCarouselIndex = carouselLength - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_locationPageController.hasClients) return;
        _locationPageController.jumpToPage(_locationCarouselIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skyline', style: TextStyle(fontWeight: FontWeight.w800)),
            Text(
              'Live weather briefing',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search locations',
            onPressed: () {
              setState(() => _isSearchVisible = !_isSearchVisible);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.bookmarks_rounded),
              tooltip: 'Saved locations',
              onPressed: _openSavedLocations,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: WeatherTheme.gradientForCondition(
                widget.dashboard?.weather.description ??
                    widget.dashboard?.weather.mainCondition,
              ),
            ),
            child: SafeArea(
              child: _buildBody(),
            ),
          ),
          if (widget.savedLocations.isNotEmpty && widget.dashboard != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: SafeArea(
                top: false,
                child: _FloatingLocationCarouselDots(
                  count: widget.savedLocations.length + 1,
                  activeIndex: _locationCarouselIndex,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (widget.isLoading) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: WeatherTheme.primarySky,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: const [WeatherLoadingView()],
        ),
      );
    }

    if (widget.dashboard == null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: WeatherTheme.primarySky,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [WeatherErrorView(onRetry: widget.onRefresh)],
        ),
      );
    }

    final pageCount = widget.savedLocations.length + 1;

    return PageView.builder(
      key: const ValueKey('saved-location-page-view'),
      controller: _locationPageController,
      itemCount: pageCount,
      onPageChanged: _handleLocationPageChanged,
      itemBuilder: (context, index) {
        final dashboard = _dashboardForPage(index);

        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          color: WeatherTheme.primarySky,
          child: ListView(
            key: ValueKey('weather-location-page-$index'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              widget.savedLocations.isEmpty ? 28 : 82,
            ),
            children: [
              if (dashboard == null)
                _SavedLocationPreparingView(
                  location: widget.savedLocations[index - 1],
                )
              else
                _WeatherPage(
                  dashboard: dashboard,
                  isSearchVisible: _isSearchVisible,
                  searchResults: widget.searchResults,
                  savedLocations: widget.savedLocations,
                  isSearching: widget.isSearching,
                  mapLayerUrls: widget.mapLayerUrls,
                  onSearch: widget.onSearch,
                  onSelectLocation: _handleSearchLocationSelected,
                  onSaveLocation: widget.onSaveLocation,
                  onRemoveSavedLocation: widget.onRemoveSavedLocation,
                ),
            ],
          ),
        );
      },
    );
  }

  WeatherDashboard? _dashboardForPage(int index) {
    if (index == 0) return widget.dashboard;
    final savedIndex = index - 1;
    if (savedIndex < 0 || savedIndex >= widget.savedLocations.length) {
      return null;
    }

    return widget
        .savedDashboards[_savedDashboardKey(widget.savedLocations[savedIndex])];
  }

  void _handleSearchLocationSelected(WeatherLocation location) {
    _suppressNextCurrentPageSelection = true;
    _selectLocationPage(0);
    widget.onSelectLocation(location);
  }

  Future<void> _openSavedLocations() async {
    final selected = await Navigator.of(context).push<WeatherLocation>(
      MaterialPageRoute(
        builder: (context) => _SavedLocationsPage(
          locations: widget.savedLocations,
          onRemove: widget.onRemoveSavedLocation,
        ),
      ),
    );
    if (selected == null || !mounted) return;

    final savedIndex = widget.savedLocations.indexWhere(
      (location) =>
          location.displayName == selected.displayName ||
          (location.lat == selected.lat && location.lon == selected.lon),
    );
    if (savedIndex >= 0) {
      _selectLocationPage(savedIndex + 1);
    }
  }

  void _selectLocationPage(int index) {
    setState(() => _locationCarouselIndex = index);
    if (!_locationPageController.hasClients) {
      _handleLocationPageChanged(index);
      return;
    }

    _locationPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleLocationPageChanged(int index) {
    if (_locationCarouselIndex != index) {
      setState(() => _locationCarouselIndex = index);
    }

    if (index == 0) {
      if (_suppressNextCurrentPageSelection) {
        _suppressNextCurrentPageSelection = false;
        return;
      }
      final selectCurrentLocation = widget.onSelectCurrentLocation;
      if (selectCurrentLocation == null) {
        widget.onRefresh();
      } else {
        selectCurrentLocation();
      }
      return;
    }

    final savedIndex = index - 1;
    if (savedIndex < 0 || savedIndex >= widget.savedLocations.length) return;

    final location = widget.savedLocations[savedIndex];
    final swipeLocation = widget.onSwipeLocation;
    if (swipeLocation == null) {
      widget.onSelectLocation(location);
    } else {
      swipeLocation(location);
    }
  }
}

class _WeatherPage extends StatelessWidget {
  const _WeatherPage({
    required this.dashboard,
    required this.isSearchVisible,
    required this.searchResults,
    required this.savedLocations,
    required this.isSearching,
    required this.mapLayerUrls,
    required this.onSearch,
    required this.onSelectLocation,
    required this.onSaveLocation,
    required this.onRemoveSavedLocation,
  });

  final WeatherDashboard dashboard;
  final bool isSearchVisible;
  final List<WeatherLocation> searchResults;
  final List<WeatherLocation> savedLocations;
  final bool isSearching;
  final Map<String, String> mapLayerUrls;
  final ValueChanged<String> onSearch;
  final ValueChanged<WeatherLocation> onSelectLocation;
  final ValueChanged<WeatherLocation>? onSaveLocation;
  final ValueChanged<WeatherLocation>? onRemoveSavedLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSearchVisible) ...[
          LocationSearchCard(
            results: searchResults,
            savedLocations: savedLocations,
            isSearching: isSearching,
            onSearch: onSearch,
            onSelect: onSelectLocation,
            onSave: onSaveLocation,
            onRemoveSaved: onRemoveSavedLocation,
          ),
          const SizedBox(height: 18),
        ],
        WeatherSummaryCard(weather: dashboard.weather),
        const SizedBox(height: 18),
        SmartDailySummaryCard(
          weather: dashboard.weather,
          forecast: dashboard.forecast,
        ),
        const SizedBox(height: 18),
        WeatherMetricGrid(weather: dashboard.weather),
        const SizedBox(height: 18),
        _ForecastSection(dashboard: dashboard),
        const SizedBox(height: 18),
        _AirSection(dashboard: dashboard),
        const SizedBox(height: 18),
        _MapSection(layerUrls: mapLayerUrls),
      ],
    );
  }
}

class _ForecastSection extends StatelessWidget {
  const _ForecastSection({required this.dashboard});

  final WeatherDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final forecast = dashboard.forecast;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Daily forecast'),
        const SizedBox(height: 12),
        if (forecast == null || forecast.days.isEmpty)
          const _EmptyFeatureCard(
            icon: Icons.calendar_month_rounded,
            title: 'Forecast unavailable',
            message: 'Refresh or choose another city to load the outlook.',
          )
        else ...[
          _ForecastSummaryCard(forecast: forecast),
          const SizedBox(height: 14),
          HourlyForecastStrip(hourly: forecast.hourly),
          const SizedBox(height: 14),
          WeatherForecastStrip(forecast: forecast),
        ],
      ],
    );
  }
}

class _LocationCarouselDots extends StatelessWidget {
  const _LocationCarouselDots({
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isActive = index == activeIndex;

          return AnimatedContainer(
            key: ValueKey('location-carousel-dot-$index'),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: isActive ? 18 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? WeatherTheme.onGlassPrimary
                  : WeatherTheme.onGlassSecondary.withValues(alpha: 0.46),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}

class _FloatingLocationCarouselDots extends StatelessWidget {
  const _FloatingLocationCarouselDots({
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        key: const ValueKey('location-carousel-floating-dots'),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: _LocationCarouselDots(
          count: count,
          activeIndex: activeIndex,
        ),
      ),
    );
  }
}

class _SavedLocationPreparingView extends StatelessWidget {
  const _SavedLocationPreparingView({required this.location});

  final WeatherLocation location;

  @override
  Widget build(BuildContext context) {
    return WeatherGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: WeatherTheme.onGlassPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preparing saved weather',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WeatherTheme.onGlassSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

String _savedDashboardKey(WeatherLocation location) {
  return '${location.lat.toStringAsFixed(4)},${location.lon.toStringAsFixed(4)}';
}

class _AirSection extends StatelessWidget {
  const _AirSection({required this.dashboard});

  final WeatherDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final airQuality = dashboard.airQuality;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Air quality outlook'),
        const SizedBox(height: 12),
        if (airQuality == null)
          const _EmptyFeatureCard(
            icon: Icons.air_rounded,
            title: 'Air quality unavailable',
            message: 'Refresh or choose another city to load air conditions.',
          )
        else ...[
          AirQualityCard(airQuality: airQuality),
          const SizedBox(height: 14),
          WeatherGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outdoor guidance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: WeatherTheme.onGlassPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _airCopy(airQuality.index),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: WeatherTheme.onGlassSecondary,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _airCopy(int index) {
    return switch (index) {
      1 => 'Great for outdoor plans. Air quality is currently clean.',
      2 => 'Comfortable for most outdoor plans.',
      3 => 'Moderate conditions. Sensitive groups may prefer shorter exposure.',
      4 => 'Poor conditions. Consider limiting heavy outdoor activity.',
      5 => 'Very poor conditions. Keep outdoor activity brief where possible.',
      _ => 'Air quality details are not available right now.',
    };
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection({required this.layerUrls});

  final Map<String, String> layerUrls;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Weather layers'),
        const SizedBox(height: 12),
        MapLayersCard(layerUrls: layerUrls),
        const SizedBox(height: 14),
        const _EmptyFeatureCard(
          icon: Icons.layers_rounded,
          title: 'Layer studio',
          message: 'Compare clouds, rain, temperature, and wind at a glance.',
        ),
      ],
    );
  }
}

class _ForecastSummaryCard extends StatelessWidget {
  const _ForecastSummaryCard({required this.forecast});

  final WeatherForecast forecast;

  @override
  Widget build(BuildContext context) {
    final warmest = forecast.days.reduce(
      (a, b) => a.maxTemp >= b.maxTemp ? a : b,
    );
    final coolest = forecast.days.reduce(
      (a, b) => a.minTemp <= b.minTemp ? a : b,
    );

    return WeatherGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next few days',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: WeatherTheme.onGlassPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: 'Warmest',
                  value: '${warmest.maxTemp.round()}°',
                  icon: Icons.wb_sunny_rounded,
                  color: WeatherTheme.sunnyAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryStat(
                  label: 'Coolest',
                  value: '${coolest.minTemp.round()}°',
                  icon: Icons.ac_unit_rounded,
                  color: WeatherTheme.rainAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WeatherTheme.glassInset.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(WeatherTheme.radiusMd),
        border: Border.all(color: WeatherTheme.glassStroke),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: WeatherTheme.onGlassSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: WeatherTheme.onGlassPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeatureCard extends StatelessWidget {
  const _EmptyFeatureCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return WeatherGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: WeatherTheme.rainAccent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: WeatherTheme.onGlassPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: WeatherTheme.onGlassSecondary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
    );
  }
}

class _SavedLocationsPage extends StatefulWidget {
  const _SavedLocationsPage({
    required this.locations,
    required this.onRemove,
  });

  final List<WeatherLocation> locations;
  final ValueChanged<WeatherLocation>? onRemove;

  @override
  State<_SavedLocationsPage> createState() => _SavedLocationsPageState();
}

class _SavedLocationsPageState extends State<_SavedLocationsPage> {
  late List<WeatherLocation> _locations;

  @override
  void initState() {
    super.initState();
    _locations = List.of(widget.locations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Saved locations',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: WeatherTheme.screenGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            children: [
              if (_locations.isEmpty)
                const _EmptyFeatureCard(
                  icon: Icons.bookmarks_rounded,
                  title: 'No saved locations',
                  message: 'Save a city from search to see it here.',
                )
              else
                WeatherGlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: _locations.map((location) {
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: const Icon(
                            Icons.location_on_rounded,
                            color: WeatherTheme.rainAccent,
                          ),
                          title: Text(
                            location.displayName,
                            style: const TextStyle(
                              color: WeatherTheme.onGlassPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: Text(
                            '${location.lat.toStringAsFixed(2)}, '
                            '${location.lon.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: WeatherTheme.onGlassSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: widget.onRemove == null
                              ? null
                              : IconButton(
                                  tooltip: 'Remove ${location.name}',
                                  icon: const Icon(Icons.close_rounded),
                                  color: WeatherTheme.onGlassSecondary,
                                  onPressed: () => _removeLocation(location),
                                ),
                          onTap: () => Navigator.of(context).pop(location),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeLocation(WeatherLocation location) {
    widget.onRemove?.call(location);
    setState(() {
      _locations = _locations
          .where(
            (saved) =>
                saved.displayName != location.displayName &&
                (saved.lat != location.lat || saved.lon != location.lon),
          )
          .toList();
    });
  }
}
