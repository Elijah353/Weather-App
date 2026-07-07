import 'package:weather_test/data/model/air_quality_model.dart';
import 'package:weather_test/data/model/forecast_model.dart';
import 'package:weather_test/data/model/weather_model.dart';

class WeatherDashboard {
  const WeatherDashboard({
    required this.weather,
    this.forecast,
    this.airQuality,
  });

  final Weather weather;
  final WeatherForecast? forecast;
  final AirQuality? airQuality;
}
