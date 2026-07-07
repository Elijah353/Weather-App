import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_test/data/controller/weather_controller.dart';
import 'package:weather_test/data/model/weather_dashboard_model.dart';
import 'package:weather_test/data/repo/weather_repo.dart';
import 'package:weather_test/data/services/api_service.dart';

void main() {
  testWidgets('uses reverse geocoded area for coordinate weather label', (
    tester,
  ) async {
    final controller = WeatherController(repo: _LocationAwareWeatherRepo());
    WeatherDashboard? dashboard;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  dashboard = await controller.fetchDashboardForCoordinates(
                    context,
                    13.1,
                    -59.61,
                  );
                },
                child: const Text('Load weather'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Load weather'));
    await tester.pumpAndSettle();

    expect(dashboard, isNotNull);
    expect(dashboard!.weather.cityName, 'Worthing, Christ Church');
    expect(dashboard!.weather.country, 'BB');
  });
}

class _LocationAwareWeatherRepo extends WeatherRepo {
  _LocationAwareWeatherRepo() : super(apiService: ApiService(apiKey: 'test'));

  @override
  Future<dynamic> fetchCurrentWeather(double lat, double lon) async {
    return <String, dynamic>{
      'weather': [
        <String, dynamic>{
          'main': 'Clouds',
          'description': 'scattered clouds',
          'icon': '03d',
        },
      ],
      'main': <String, dynamic>{
        'temp': 28.4,
        'humidity': 78,
        'feels_like': 31.2,
        'temp_min': 26.5,
        'temp_max': 30.1,
        'pressure': 1012,
      },
      'visibility': 10000,
      'wind': <String, dynamic>{'speed': 6.4},
      'name': 'Bridgetown',
      'sys': <String, dynamic>{
        'sunrise': 1783393260,
        'sunset': 1783434540,
        'country': 'BB',
      },
      'coord': <String, dynamic>{'lat': lat, 'lon': lon},
    };
  }

  @override
  Future<dynamic> fetchFiveDayForecast(double lat, double lon) async {
    return <String, dynamic>{'list': <dynamic>[]};
  }

  @override
  Future<dynamic> fetchCurrentAirPollution(double lat, double lon) async {
    return <String, dynamic>{'list': <dynamic>[]};
  }

  @override
  Future<dynamic> reverseGeocode(double lat, double lon,
      {int limit = 5}) async {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'name': 'Worthing',
        'state': 'Christ Church',
        'country': 'BB',
        'lat': lat,
        'lon': lon,
      },
    ];
  }
}
