import 'package:flutter/material.dart';
import 'package:weather_test/data/controller/weather_controller.dart';
import 'package:weather_test/data/model/location_model.dart';
import 'package:weather_test/data/model/weather_dashboard_model.dart';
import 'package:weather_test/view/screens/weather/weather_dashboard_shell.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherDashboard? _dashboard;
  List<WeatherLocation> _searchResults = const [];
  List<WeatherLocation> _savedLocations = const [];
  Map<String, WeatherDashboard> _savedDashboards = const {};
  bool _loading = false;
  bool _searching = false;
  late final WeatherController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WeatherController();
    _getWeatherFromLocation();
  }

  Future<void> _getWeatherFromLocation({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _loading = true);
    }
    final dashboard =
        await _controller.fetchDashboardFromCurrentLocation(context);
    if (!mounted) return;

    setState(() {
      _dashboard = dashboard;
      _searchResults = const [];
      if (showLoading) {
        _loading = false;
      }
    });
  }

  Future<void> _loadLocation(
    WeatherLocation location, {
    bool showLoading = true,
  }) async {
    if (showLoading) {
      setState(() => _loading = true);
    }
    final dashboard = await _controller.fetchDashboardForCoordinates(
      context,
      location.lat,
      location.lon,
      successTitle: 'Location selected',
    );
    if (!mounted) return;

    setState(() {
      _dashboard = dashboard;
      _searchResults = const [];
      if (showLoading) {
        _loading = false;
      }
    });
  }

  void _saveLocation(WeatherLocation location) {
    final alreadySaved = _savedLocations.any(
      (saved) =>
          saved.displayName == location.displayName ||
          (saved.lat == location.lat && saved.lon == location.lon),
    );
    if (alreadySaved) return;

    setState(() {
      _savedLocations = [..._savedLocations, location];
    });
    _cacheSavedLocationDashboard(location);
  }

  void _removeSavedLocation(WeatherLocation location) {
    final key = _savedDashboardKey(location);
    setState(() {
      _savedLocations = _savedLocations
          .where(
            (saved) =>
                saved.displayName != location.displayName &&
                (saved.lat != location.lat || saved.lon != location.lon),
          )
          .toList();
      _savedDashboards = Map.of(_savedDashboards)..remove(key);
    });
  }

  Future<void> _cacheSavedLocationDashboard(WeatherLocation location) async {
    final key = _savedDashboardKey(location);
    if (_savedDashboards.containsKey(key)) return;

    final dashboard = await _controller.fetchDashboardForCoordinates(
      context,
      location.lat,
      location.lon,
      successTitle: 'Saved location ready',
    );
    if (!mounted || dashboard == null) return;

    setState(() {
      _savedDashboards = {
        ..._savedDashboards,
        key: dashboard,
      };
    });
  }

  Future<void> _searchLocations(String query) async {
    setState(() => _searching = true);
    final results = await _controller.searchLocations(query);
    if (!mounted) return;

    setState(() {
      _searchResults = results;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WeatherDashboardShell(
      dashboard: _dashboard,
      isLoading: _loading,
      isSearching: _searching,
      searchResults: _searchResults,
      savedLocations: _savedLocations,
      savedDashboards: _savedDashboards,
      mapLayerUrls: _controller.weatherMapLayers(),
      onRefresh: _getWeatherFromLocation,
      onSearch: _searchLocations,
      onSelectLocation: _loadLocation,
      onSelectCurrentLocation: () => _getWeatherFromLocation(
        showLoading: false,
      ),
      onSwipeLocation: _cacheSavedLocationDashboard,
      onSaveLocation: _saveLocation,
      onRemoveSavedLocation: _removeSavedLocation,
    );
  }

  String _savedDashboardKey(WeatherLocation location) {
    return '${location.lat.toStringAsFixed(4)},${location.lon.toStringAsFixed(4)}';
  }
}
