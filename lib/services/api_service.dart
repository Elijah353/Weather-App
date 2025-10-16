import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_test/model/weather_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<Weather?> fetchWeather(double lat, double lon) async {
  final apiKey = dotenv.env['API_KEY'];
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);

    print('------Weather Data------');
    print('url: $url');
    print('status: ${response.statusCode}');
    print('body: ${response.body}');
    return Weather.fromJson(jsonData);
  } else {
    print('Error: ${response.statusCode}');
    return null;
  }
}

Future<Weather?> fetchWeatherFromCurrentLocation() async {
  // Request location permission
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    print('Location permission denied');
    return null;
  }

  // Get current position
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  double lat = position.latitude;
  double lon = position.longitude;

  final apiKey = dotenv.env['API_KEY'];
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);

    print('------Weather Data------');
    print('url: $url');
    print('status: ${response.statusCode}');
    print('body: ${response.body}');
    return Weather.fromJson(jsonData);
  } else {
    print('Error: ${response.statusCode}');
    return null;
  }
}
