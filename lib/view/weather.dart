import 'package:flutter/material.dart';
import 'package:weather_test/services/api_service.dart';
import 'package:weather_test/model/weather_model.dart';
import 'package:weather_test/services/geocoding_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  Weather? _weather;
  bool _loading = false;

  Future<void> _searchWeather() async {
    final city = _controller.text.trim();
    if (city.isEmpty) return;

    setState(() => _loading = true);

    final coords = await getCoordinates(city);
    if (coords != null) {
      final weather = await fetchWeather(coords['lat']!, coords['lon']!);
      setState(() {
        _weather = weather;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter a city name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchWeather,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const CircularProgressIndicator()
            else if (_weather != null)
              Column(
                children: [
                  Image.network(
                    'https://openweathermap.org/img/wn/${_weather!.icon}@2x.png',
                  ),
                  Text(
                    _weather!.cityName.isEmpty
                        ? 'Unknown location'
                        : '${_weather!.cityName}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(_weather!.country),
                  Text(_weather!.description),
                  Text('🌡️ ${_weather!.temperature.toStringAsFixed(1)}°C'),
                  Text('💧 ${_weather!.humidity}% humidity'),
                  Text('🌬️ ${_weather!.windSpeed} m/s wind'),
                  Text('Sunrise: ${_weather!.sunrise.hour}:${_weather!.sunrise.minute.toString().padLeft(2, '0')}'),
                  Text('Sunset: ${_weather!.sunset.hour}:${_weather!.sunset.minute.toString().padLeft(2, '0')}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
