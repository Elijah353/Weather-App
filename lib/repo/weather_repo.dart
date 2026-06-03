import 'package:weather_test/services/api_service.dart';
import 'package:weather_test/services/url_container.dart';

class WeatherRepo {
  WeatherRepo({ApiService? apiService})
      : apiService = apiService ?? ApiService();

  final ApiService apiService;

  Future<dynamic> fetchWeatherData(double lat, double lon) async {
    final params = <String, dynamic>{
      'lat': '$lat',
      'lon': '$lon',
      'units': 'metric',
    };

    return apiService.sendRequest(
      Method.get,
      url: UrlContainer.weather,
      params: params,
    );
  }
}
