import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_test/data/model/air_quality_model.dart';
import 'package:weather_test/data/model/forecast_model.dart';
import 'package:weather_test/data/model/location_model.dart';
import 'package:weather_test/view/screens/weather/widgets/air_quality_card.dart';
import 'package:weather_test/view/screens/weather/widgets/location_search_card.dart';
import 'package:weather_test/view/screens/weather/widgets/map_layers_card.dart';
import 'package:weather_test/view/screens/weather/widgets/hourly_forecast_strip.dart';
import 'package:weather_test/view/screens/weather/widgets/smart_daily_summary_card.dart';
import 'package:weather_test/view/screens/weather/widgets/weather_forecast_strip.dart';
import 'package:weather_test/data/model/weather_model.dart';

void main() {
  testWidgets('forecast view shows scan-friendly daily rows', (tester) async {
    final forecast = WeatherForecast(days: [
      ForecastDay(
        date: DateTime(2026, 7, 7),
        minTemp: 26.1,
        maxTemp: 31.2,
        description: 'Scattered clouds',
        icon: '03d',
      ),
      ForecastDay(
        date: DateTime(2026, 7, 8),
        minTemp: 25.8,
        maxTemp: 30.4,
        description: 'Clear sky',
        icon: '01d',
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherForecastStrip(forecast: forecast),
        ),
      ),
    );

    expect(find.text('5-day outlook'), findsOneWidget);
    expect(find.text('Scattered clouds'), findsOneWidget);
    expect(find.text('Clear sky'), findsOneWidget);
    expect(find.text('High 31°'), findsOneWidget);
    expect(find.text('Low 26°'), findsWidgets);
    expect(find.byKey(const ValueKey('forecast-range-bar')), findsWidgets);
  });

  testWidgets('hourly forecast strip shows upcoming conditions', (
    tester,
  ) async {
    final hourly = [
      ForecastHour(
        time: DateTime(2026, 7, 7, 9),
        temperature: 28.4,
        feelsLike: 31.2,
        precipitationChance: 0.42,
        description: 'Light rain',
        icon: '10d',
      ),
      ForecastHour(
        time: DateTime(2026, 7, 7, 12),
        temperature: 31.2,
        feelsLike: 34.0,
        precipitationChance: 0.08,
        description: 'Scattered clouds',
        icon: '03d',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HourlyForecastStrip(hourly: hourly),
        ),
      ),
    );

    expect(find.text('Next 24 hours'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('28°'), findsOneWidget);
    expect(find.text('42%'), findsOneWidget);
    expect(find.text('Light rain'), findsOneWidget);
  });

  testWidgets('smart daily summary turns weather into practical guidance', (
    tester,
  ) async {
    final weather = Weather(
      mainCondition: 'Rain',
      description: 'light rain',
      icon: '10d',
      temperature: 28.4,
      feelsLike: 31.2,
      tempMin: 26.5,
      tempMax: 30.1,
      pressure: 1012,
      humidity: 82,
      visibility: 10000,
      windSpeed: 6.4,
      cityName: 'Worthing',
      sunrise: DateTime(2026, 7, 7, 5, 41),
      sunset: DateTime(2026, 7, 7, 18, 29),
      country: 'BB',
      coord: Coord(lon: -59.61, lat: 13.1),
    );
    final forecast = WeatherForecast(
      days: const [],
      hourly: [
        ForecastHour(
          time: DateTime(2026, 7, 7, 9),
          temperature: 28.4,
          feelsLike: 31.2,
          precipitationChance: 0.52,
          description: 'Light rain',
          icon: '10d',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmartDailySummaryCard(weather: weather, forecast: forecast),
        ),
      ),
    );

    expect(find.text("Today's briefing"), findsNothing);
    expect(find.textContaining('rain is likely'), findsOneWidget);
    expect(find.textContaining('feels warmer'), findsOneWidget);
  });

  testWidgets('air quality card shows AQI and pollutants', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AirQualityCard(
            airQuality: AirQuality(
              index: 2,
              pm25: 4.7,
              pm10: 12.1,
              ozone: 34.2,
              nitrogenDioxide: 9.4,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Air Quality'), findsOneWidget);
    expect(find.text('Fair'), findsOneWidget);
    expect(find.text('PM2.5'), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);
    expect(find.text('PM10'), findsOneWidget);
    expect(find.text('12.1'), findsOneWidget);
  });

  testWidgets('location search card submits queries and selects results',
      (tester) async {
    String? submittedQuery;
    WeatherLocation? selectedLocation;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationSearchCard(
            results: const [
              WeatherLocation(
                name: 'Bridgetown',
                state: 'Saint Michael',
                country: 'BB',
                lat: 13.1,
                lon: -59.61,
              ),
            ],
            isSearching: false,
            onSearch: (query) => submittedQuery = query,
            onSelect: (location) => selectedLocation = location,
            savedLocations: const [],
            onSave: (_) {},
            onRemoveSaved: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Bridgetown');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(submittedQuery, 'Bridgetown');
    expect(find.text('Bridgetown, Saint Michael, BB'), findsOneWidget);

    await tester.tap(find.text('Bridgetown, Saint Michael, BB'));
    expect(selectedLocation?.name, 'Bridgetown');
  });

  testWidgets('location search card saves results without listing saved places',
      (tester) async {
    WeatherLocation? savedLocation;
    const bridgetown = WeatherLocation(
      name: 'Bridgetown',
      state: 'Saint Michael',
      country: 'BB',
      lat: 13.1,
      lon: -59.61,
    );
    const worthing = WeatherLocation(
      name: 'Worthing',
      state: 'Christ Church',
      country: 'BB',
      lat: 13.07,
      lon: -59.58,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationSearchCard(
            results: const [bridgetown],
            savedLocations: const [worthing],
            isSearching: false,
            onSearch: (_) {},
            onSelect: (_) {},
            onSave: (location) => savedLocation = location,
            onRemoveSaved: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Saved'), findsNothing);
    expect(find.text('Worthing'), findsNothing);

    await tester.tap(find.byTooltip('Save Bridgetown'));
    expect(savedLocation?.name, 'Bridgetown');
  });

  testWidgets('map layers card describes user-facing weather layers',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapLayersCard(
            layerUrls: const {
              'Clouds':
                  'https://tile.openweathermap.org/map/clouds_new/3/4/2.png',
              'Precipitation':
                  'https://tile.openweathermap.org/map/precipitation_new/3/4/2.png',
            },
          ),
        ),
      ),
    );

    expect(find.text('Conditions map'), findsOneWidget);
    expect(
      find.text('Clouds, rain, temperature, and wind layers are available.'),
      findsOneWidget,
    );
    expect(find.text('Clouds'), findsOneWidget);
    expect(find.text('Precipitation'), findsOneWidget);
  });
}
