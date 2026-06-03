import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_test/model/weather_model.dart';
import 'package:weather_test/repo/weather_repo.dart';
import 'package:weather_test/view/components/custom_snackbar.dart';

class WeatherController {
  WeatherController({WeatherRepo? repo}) : _repo = repo ?? WeatherRepo();

  final WeatherRepo _repo;

  Future<Weather?> fetchWeatherFromCurrentLocation(BuildContext context) async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      CustomSnackBar.show(
        context,
        type: SnackType.error,
        message: 'Location permission denied',
      );
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final lat = position.latitude;
    final lon = position.longitude;

    final data = await _repo.fetchWeatherData(lat, lon);
    if (data == null) {
      CustomSnackBar.show(
        context,
        type: SnackType.error,
        message: 'Unable to fetch weather for your location',
      );
      return null;
    }

    final weather = Weather.fromJson(data);
    CustomSnackBar.show(
      context,
      type: SnackType.success,
      message: weather.cityName.isEmpty
          ? 'Using current coordinates'
          : '${weather.cityName}, ${weather.country}',
      title: 'Location updated',
    );
    return weather;
  }

  Future<Weather?> fetchWeatherForCoordinates(
    BuildContext context,
    double lat,
    double lon,
  ) async {
    final data = await _repo.fetchWeatherData(lat, lon);
    if (data == null) {
      CustomSnackBar.show(
        context,
        type: SnackType.error,
        message: 'Unable to fetch weather for that location',
      );
      return null;
    }

    final weather = Weather.fromJson(data);
    CustomSnackBar.show(
      context,
      type: SnackType.info,
      message: weather.cityName.isEmpty
          ? 'Coordinates selected'
          : '${weather.cityName}, ${weather.country}',
      title: 'Weather loaded',
    );
    return weather;
  }
}
