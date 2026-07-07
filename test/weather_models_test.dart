import 'package:flutter_test/flutter_test.dart';
import 'package:weather_test/data/model/air_quality_model.dart';
import 'package:weather_test/data/model/forecast_model.dart';
import 'package:weather_test/data/model/location_model.dart';

void main() {
  test('parses daily forecast summaries from 5 day forecast response', () {
    final forecast = WeatherForecast.fromJson({
      'list': [
        {
          'dt_txt': '2026-07-07 09:00:00',
          'main': {'temp_min': 26.1, 'temp_max': 29.7},
          'weather': [
            {'description': 'light rain', 'icon': '10d'}
          ],
        },
        {
          'dt_txt': '2026-07-07 12:00:00',
          'main': {'temp_min': 27.4, 'temp_max': 31.2},
          'weather': [
            {'description': 'scattered clouds', 'icon': '03d'}
          ],
        },
        {
          'dt_txt': '2026-07-08 12:00:00',
          'main': {'temp_min': 25.8, 'temp_max': 30.4},
          'weather': [
            {'description': 'clear sky', 'icon': '01d'}
          ],
        },
      ],
    });

    expect(forecast.days, hasLength(2));
    expect(forecast.days.first.description, 'Scattered clouds');
    expect(forecast.days.first.minTemp.round(), 26);
    expect(forecast.days.first.maxTemp.round(), 31);
    expect(forecast.days.last.description, 'Clear sky');
    expect(forecast.hourly, hasLength(3));
    expect(forecast.hourly.first.time, DateTime(2026, 7, 7, 9));
    expect(forecast.hourly.first.temperature.round(), 28);
    expect(forecast.hourly.first.precipitationChance, 0);
    expect(forecast.hourly.first.description, 'Light rain');
  });

  test('parses air quality index and pollutant components', () {
    final airQuality = AirQuality.fromJson({
      'list': [
        {
          'main': {'aqi': 2},
          'components': {
            'pm2_5': 4.7,
            'pm10': 12.1,
            'o3': 34.2,
            'no2': 9.4,
          },
        }
      ],
    });

    expect(airQuality.index, 2);
    expect(airQuality.label, 'Fair');
    expect(airQuality.pm25, 4.7);
    expect(airQuality.pm10, 12.1);
    expect(airQuality.ozone, 34.2);
    expect(airQuality.nitrogenDioxide, 9.4);
  });

  test('parses geocoding location search results', () {
    final locations = WeatherLocation.listFromJson([
      {
        'name': 'Bridgetown',
        'country': 'BB',
        'state': 'Saint Michael',
        'lat': 13.1,
        'lon': -59.61,
      }
    ]);

    expect(locations, hasLength(1));
    expect(locations.first.displayName, 'Bridgetown, Saint Michael, BB');
    expect(locations.first.lat, 13.1);
    expect(locations.first.lon, -59.61);
  });
}
