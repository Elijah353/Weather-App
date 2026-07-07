import 'package:weather_test/data/services/api_service.dart';
import 'package:weather_test/data/services/url_container.dart';

class WeatherRepo {
  WeatherRepo({ApiService? apiService})
      : apiService = apiService ?? ApiService();

  final ApiService apiService;

  Future<dynamic> fetchWeatherData(double lat, double lon) async {
    return fetchCurrentWeather(lat, lon);
  }

  Future<dynamic> fetchCurrentWeather(double lat, double lon) async {
    final params = <String, dynamic>{
      'lat': '$lat',
      'lon': '$lon',
      'units': 'metric',
    };

    return apiService.sendRequest(
      Method.get,
      url: UrlContainer.currentWeather,
      params: params,
    );
  }

  Future<dynamic> fetchFiveDayForecast(double lat, double lon) async {
    final params = <String, dynamic>{
      'lat': '$lat',
      'lon': '$lon',
      'units': 'metric',
    };

    return apiService.sendRequest(
      Method.get,
      url: UrlContainer.fiveDayForecast,
      params: params,
    );
  }

  Future<dynamic> fetchCurrentAirPollution(double lat, double lon) async {
    final params = <String, dynamic>{
      'lat': '$lat',
      'lon': '$lon',
    };

    return apiService.sendRequest(
      Method.get,
      url: UrlContainer.airPollutionCurrent,
      params: params,
    );
  }

  Future<dynamic> fetchAirPollutionForecast(double lat, double lon) async {
    final params = <String, dynamic>{
      'lat': '$lat',
      'lon': '$lon',
    };

    return apiService.sendRequest(
      Method.get,
      url: UrlContainer.airPollutionForecast,
      params: params,
    );
  }

  Future<dynamic> searchLocations(String query, {int limit = 5}) async {
    final params = <String, dynamic>{
      'q': query,
      'limit': '$limit',
    };

    return apiService.sendRequest(
      Method.get,
      url: UrlContainer.geocodingDirect,
      params: params,
    );
  }

  Future<dynamic> reverseGeocode(
    double lat,
    double lon, {
    int limit = 5,
  }) async {
    final params = <String, dynamic>{
      'lat': '$lat',
      'lon': '$lon',
      'limit': '$limit',
    };

    return apiService.sendRequest(
      Method.get,
      url: UrlContainer.geocodingReverse,
      params: params,
    );
  }

  String buildWeatherMapTileUrl(String layer, int z, int x, int y) {
    return UrlContainer.weatherMapTile(layer, z, x, y);
  }
}
