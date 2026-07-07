import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/view/screens/weather/weather_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: WeatherTheme.light,
      home: const WeatherScreen(),
    );
  }
}
