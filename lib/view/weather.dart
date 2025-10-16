import 'package:flutter/material.dart';
import 'package:weather_test/services/api_service.dart';
import 'package:weather_test/model/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Weather? _weather;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getWeatherFromLocation();
  }

  Future<void> _getWeatherFromLocation() async {
    setState(() => _loading = true);
    final weather = await fetchWeatherFromCurrentLocation();
    setState(() {
      _weather = weather;
      _loading = false;
    });
    if (weather == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get location or weather')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _getWeatherFromLocation,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _getWeatherFromLocation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _loading
                ? const CircularProgressIndicator()
                : _weather != null
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 32, horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                  'https://openweathermap.org/img/wn/${_weather!.icon}@4x.png',
                                  width: 120,
                                  height: 120,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _weather!.cityName.isEmpty
                                      ? 'Unknown location'
                                      : '${_weather!.cityName}, ${_weather!.country}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _weather!.description,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _WeatherInfoTile(
                                      icon: Icons.thermostat,
                                      label: 'Temp',
                                      value:
                                          '${_weather!.temperature.toStringAsFixed(1)}°C',
                                    ),
                                    _WeatherInfoTile(
                                      icon: Icons.water_drop,
                                      label: 'Humidity',
                                      value: '${_weather!.humidity}',
                                    ),
                                    _WeatherInfoTile(
                                      icon: Icons.air,
                                      label: 'Wind',
                                      value: '${_weather!.windSpeed} m/s',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _WeatherInfoTile(
                                      icon: Icons.wb_sunny,
                                      label: 'Sunrise',
                                      value:
                                          '${_weather!.sunrise.hour}:${_weather!.sunrise.minute.toString().padLeft(2, '0')}',
                                    ),
                                    _WeatherInfoTile(
                                      icon: Icons.nights_stay,
                                      label: 'Sunset',
                                      value:
                                          '${_weather!.sunset.hour}:${_weather!.sunset.minute.toString().padLeft(2, '0')}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade400, size: 64),
                            const SizedBox(height: 16),
                            const Text(
                              'Unable to fetch weather data.',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}

class _WeatherInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}
