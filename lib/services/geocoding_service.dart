import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, double>?> getCoordinates(String cityName) async {
  const apiKey = '7650aedf73f5ec70df8e749f2695c14e'; // replace with your OpenWeatherMap key
  final url = Uri.parse(
    'https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    print('------Geocoding Data------');
    print('url: $url');
    print('status: ${response.statusCode}');
    print('body: ${response.body}');

    if (data.isNotEmpty) {
      final lat = data[0]['lat'];
      final lon = data[0]['lon'];
      return {'lat': lat, 'lon': lon};
    } else {
      print('City not found.');
      return null;
    }
  } else {
    print('Error: ${response.statusCode}');
    return null;
  }
}
