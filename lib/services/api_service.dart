import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_test/model/weather_model.dart';

Future<Weather?> fetchWeather(double lat, double lon) async {
  const apiKey = '7650aedf73f5ec70df8e749f2695c14e';
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey',
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
