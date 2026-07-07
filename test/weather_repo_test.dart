import 'package:flutter_test/flutter_test.dart';
import 'package:weather_test/data/repo/weather_repo.dart';
import 'package:weather_test/data/services/api_service.dart';
import 'package:weather_test/data/services/url_container.dart';

void main() {
  group('UrlContainer', () {
    test('exposes free OpenWeather API endpoints', () {
      expect(
        UrlContainer.currentWeather,
        'https://api.openweathermap.org/data/2.5/weather',
      );
      expect(
        UrlContainer.fiveDayForecast,
        'https://api.openweathermap.org/data/2.5/forecast',
      );
      expect(
        UrlContainer.airPollutionCurrent,
        'https://api.openweathermap.org/data/2.5/air_pollution',
      );
      expect(
        UrlContainer.airPollutionForecast,
        'https://api.openweathermap.org/data/2.5/air_pollution/forecast',
      );
      expect(
        UrlContainer.geocodingDirect,
        'https://api.openweathermap.org/geo/1.0/direct',
      );
      expect(
        UrlContainer.geocodingReverse,
        'https://api.openweathermap.org/geo/1.0/reverse',
      );
    });

    test('builds weather map tile URLs', () {
      expect(
        UrlContainer.weatherMapTile('precipitation_new', 4, 8, 6),
        'https://tile.openweathermap.org/map/precipitation_new/4/8/6.png',
      );
    });
  });

  group('WeatherRepo', () {
    late _RecordingApiService apiService;
    late WeatherRepo repo;

    setUp(() {
      apiService = _RecordingApiService();
      repo = WeatherRepo(apiService: apiService);
    });

    test('fetches current weather with coordinates and metric units', () async {
      await repo.fetchCurrentWeather(13.1, -59.61);

      expect(apiService.lastMethod, Method.get);
      expect(apiService.lastUrl, UrlContainer.currentWeather);
      expect(apiService.lastParams, {
        'lat': '13.1',
        'lon': '-59.61',
        'units': 'metric',
      });
    });

    test('fetches 5 day forecast with coordinates and metric units', () async {
      await repo.fetchFiveDayForecast(13.1, -59.61);

      expect(apiService.lastUrl, UrlContainer.fiveDayForecast);
      expect(apiService.lastParams, {
        'lat': '13.1',
        'lon': '-59.61',
        'units': 'metric',
      });
    });

    test('fetches current and forecast air pollution by coordinates', () async {
      await repo.fetchCurrentAirPollution(13.1, -59.61);

      expect(apiService.lastUrl, UrlContainer.airPollutionCurrent);
      expect(apiService.lastParams, {
        'lat': '13.1',
        'lon': '-59.61',
      });

      await repo.fetchAirPollutionForecast(13.1, -59.61);

      expect(apiService.lastUrl, UrlContainer.airPollutionForecast);
      expect(apiService.lastParams, {
        'lat': '13.1',
        'lon': '-59.61',
      });
    });

    test('searches and reverse geocodes locations', () async {
      await repo.searchLocations('Bridgetown', limit: 3);

      expect(apiService.lastUrl, UrlContainer.geocodingDirect);
      expect(apiService.lastParams, {
        'q': 'Bridgetown',
        'limit': '3',
      });

      await repo.reverseGeocode(13.1, -59.61, limit: 2);

      expect(apiService.lastUrl, UrlContainer.geocodingReverse);
      expect(apiService.lastParams, {
        'lat': '13.1',
        'lon': '-59.61',
        'limit': '2',
      });
    });

    test('builds weather map tile URLs through the repo', () {
      expect(
        repo.buildWeatherMapTileUrl('clouds_new', 3, 4, 2),
        'https://tile.openweathermap.org/map/clouds_new/3/4/2.png',
      );
    });
  });
}

class _RecordingApiService extends ApiService {
  _RecordingApiService() : super(apiKey: 'test-key');

  Method? lastMethod;
  String? lastUrl;
  Map<String, dynamic>? lastParams;

  @override
  Future<dynamic> sendRequest(
    Method method, {
    url,
    params,
    headers,
    Object? body,
  }) async {
    lastMethod = method;
    lastUrl = url as String;
    lastParams = Map<String, dynamic>.from(params as Map);
    return <String, dynamic>{'ok': true};
  }
}
