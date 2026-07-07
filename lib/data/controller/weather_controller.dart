import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_test/data/model/air_quality_model.dart';
import 'package:weather_test/data/model/forecast_model.dart';
import 'package:weather_test/data/model/location_model.dart';
import 'package:weather_test/data/model/weather_dashboard_model.dart';
import 'package:weather_test/data/model/weather_model.dart';
import 'package:weather_test/data/repo/weather_repo.dart';
import 'package:weather_test/view/components/custom_snackbar.dart';

class WeatherController {
  WeatherController({WeatherRepo? repo}) : _repo = repo ?? WeatherRepo();

  final WeatherRepo _repo;

  Future<WeatherDashboard?> fetchDashboardFromCurrentLocation(
    BuildContext context,
  ) async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!context.mounted) return null;
      CustomSnackBar.show(
        context,
        type: SnackType.error,
        message: 'Location permission denied',
      );
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    if (!context.mounted) return null;

    return fetchDashboardForCoordinates(
      context,
      position.latitude,
      position.longitude,
      successTitle: 'Location updated',
    );
  }

  Future<WeatherDashboard?> fetchDashboardForCoordinates(
    BuildContext context,
    double lat,
    double lon, {
    String successTitle = 'Weather loaded',
  }) async {
    final responses = await Future.wait<dynamic>([
      _repo.fetchCurrentWeather(lat, lon),
      _repo.fetchFiveDayForecast(lat, lon),
      _repo.fetchCurrentAirPollution(lat, lon),
    ]);

    final weatherData = responses[0];
    if (weatherData == null) {
      if (!context.mounted) return null;
      CustomSnackBar.show(
        context,
        type: SnackType.error,
        message: 'Unable to fetch weather for that location',
      );
      return null;
    }

    var weather = Weather.fromJson(weatherData as Map<String, dynamic>);
    final locations = WeatherLocation.listFromJson(
      await _repo.reverseGeocode(lat, lon, limit: 1),
    );
    if (locations.isNotEmpty) {
      final location = locations.first;
      weather = weather.copyWith(
        cityName: _localizedCityName(location),
        country: location.country.isEmpty ? weather.country : location.country,
      );
    }

    final forecastData = responses[1];
    final airQualityData = responses[2];
    final dashboard = WeatherDashboard(
      weather: weather,
      forecast: forecastData is Map<String, dynamic>
          ? WeatherForecast.fromJson(forecastData)
          : null,
      airQuality: airQualityData is Map<String, dynamic>
          ? AirQuality.fromJson(airQualityData)
          : null,
    );

    if (!context.mounted) return dashboard;
    CustomSnackBar.show(
      context,
      type: SnackType.success,
      message: weather.cityName.isEmpty
          ? 'Using current coordinates'
          : '${weather.cityName}, ${weather.country}',
      title: successTitle,
    );

    return dashboard;
  }

  Future<List<WeatherLocation>> searchLocations(String query) async {
    final data = await _repo.searchLocations(query, limit: 5);
    return WeatherLocation.listFromJson(data);
  }

  Map<String, String> weatherMapLayers() {
    return {
      'Clouds': _repo.buildWeatherMapTileUrl('clouds_new', 3, 4, 2),
      'Precipitation':
          _repo.buildWeatherMapTileUrl('precipitation_new', 3, 4, 2),
      'Temperature': _repo.buildWeatherMapTileUrl('temp_new', 3, 4, 2),
      'Wind': _repo.buildWeatherMapTileUrl('wind_new', 3, 4, 2),
    };
  }

  Future<Weather?> fetchWeatherFromCurrentLocation(BuildContext context) async {
    final dashboard = await fetchDashboardFromCurrentLocation(context);
    return dashboard?.weather;
  }

  Future<Weather?> fetchWeatherForCoordinates(
    BuildContext context,
    double lat,
    double lon,
  ) async {
    final dashboard = await fetchDashboardForCoordinates(context, lat, lon);
    return dashboard?.weather;
  }

  String _localizedCityName(WeatherLocation location) {
    final state = location.state;
    if (state == null || state.isEmpty) {
      return location.name;
    }

    return '${location.name}, $state';
  }
}
