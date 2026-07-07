import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_test/data/model/air_quality_model.dart';
import 'package:weather_test/data/model/forecast_model.dart';
import 'package:weather_test/data/model/location_model.dart';
import 'package:weather_test/data/model/weather_dashboard_model.dart';
import 'package:weather_test/data/model/weather_model.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/view/screens/weather/weather_dashboard_shell.dart';

void main() {
  testWidgets('dashboard shell shows weather features on one page',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WeatherDashboardShell(
          dashboard: _dashboard(),
          isLoading: false,
          isSearching: false,
          searchResults: const [],
          savedLocations: const [
            WeatherLocation(
              name: 'Worthing',
              state: 'Christ Church',
              country: 'BB',
              lat: 13.07,
              lon: -59.58,
            ),
          ],
          mapLayerUrls: const {
            'Clouds': 'clouds',
            'Rain': 'rain',
          },
          onRefresh: () async {},
          onSearch: (_) {},
          onSelectLocation: (_) {},
        ),
      ),
    );

    expect(find.text('Weather intelligence'), findsNothing);
    expect(find.text('Today at a glance'), findsNothing);
    expect(find.text("Today's briefing"), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.byTooltip('Search locations'), findsOneWidget);
    expect(find.byTooltip('Refresh'), findsNothing);
    expect(find.byTooltip('Saved locations'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('location-carousel-floating-dots')),
      findsOneWidget,
    );
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Daily forecast'), findsOneWidget);
    expect(find.text('Next 24 hours'), findsOneWidget);
    expect(find.text('Next few days'), findsOneWidget);
    expect(find.text('Warmest'), findsOneWidget);
    expect(find.text('Coolest'), findsOneWidget);
    expect(find.text('Air quality outlook'), findsOneWidget);
    expect(find.text('Outdoor guidance'), findsOneWidget);
    expect(find.text('Conditions map'), findsOneWidget);
    expect(find.text('Layer studio'), findsOneWidget);
  });

  testWidgets('app bar search action reveals the home search field',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WeatherDashboardShell(
          dashboard: _dashboard(),
          isLoading: false,
          isSearching: false,
          searchResults: const [],
          mapLayerUrls: const {},
          onRefresh: () async {},
          onSearch: (_) {},
          onSelectLocation: (_) {},
        ),
      ),
    );

    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.byTooltip('Search locations'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Search city'), findsOneWidget);
  });

  testWidgets('saved locations page selects a location and returns home', (
    tester,
  ) async {
    WeatherLocation? selectedLocation;
    WeatherLocation? swipedLocation;

    await tester.pumpWidget(
      MaterialApp(
        home: WeatherDashboardShell(
          dashboard: _dashboard(),
          isLoading: false,
          isSearching: false,
          searchResults: const [],
          savedLocations: const [
            WeatherLocation(
              name: 'Worthing',
              state: 'Christ Church',
              country: 'BB',
              lat: 13.07,
              lon: -59.58,
            ),
          ],
          mapLayerUrls: const {},
          onRefresh: () async {},
          onSearch: (_) {},
          onSelectLocation: (location) => selectedLocation = location,
          onSwipeLocation: (location) => swipedLocation = location,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Saved locations'));
    await tester.pumpAndSettle();

    expect(find.text('Saved locations'), findsOneWidget);
    expect(find.text('Worthing, Christ Church, BB'), findsOneWidget);

    await tester.tap(find.text('Worthing, Christ Church, BB'));
    await tester.pumpAndSettle();

    expect(selectedLocation, isNull);
    expect(swipedLocation?.name, 'Worthing');
    expect(find.text('Saved locations'), findsNothing);
    expect(find.text('Today at a glance'), findsNothing);
  });

  testWidgets('saved locations page removes locations immediately', (
    tester,
  ) async {
    WeatherLocation? removedLocation;

    await tester.pumpWidget(
      MaterialApp(
        home: WeatherDashboardShell(
          dashboard: _dashboard(),
          isLoading: false,
          isSearching: false,
          searchResults: const [],
          savedLocations: const [
            WeatherLocation(
              name: 'Worthing',
              state: 'Christ Church',
              country: 'BB',
              lat: 13.07,
              lon: -59.58,
            ),
          ],
          mapLayerUrls: const {},
          onRefresh: () async {},
          onSearch: (_) {},
          onSelectLocation: (_) {},
          onRemoveSavedLocation: (location) => removedLocation = location,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Saved locations'));
    await tester.pumpAndSettle();

    expect(find.text('Worthing, Christ Church, BB'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove Worthing'));
    await tester.pumpAndSettle();

    expect(removedLocation?.name, 'Worthing');
    expect(find.text('Worthing, Christ Church, BB'), findsNothing);
    expect(find.text('No saved locations'), findsOneWidget);
  });

  testWidgets('selecting search result from saved page returns to current page',
      (
    tester,
  ) async {
    WeatherLocation? selectedLocation;
    WeatherLocation? swipedLocation;
    var currentLocationCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: WeatherDashboardShell(
          dashboard: _dashboard(),
          isLoading: false,
          isSearching: false,
          searchResults: const [
            WeatherLocation(
              name: 'Speightstown',
              state: 'Saint Peter',
              country: 'BB',
              lat: 13.25,
              lon: -59.64,
            ),
          ],
          savedLocations: const [
            WeatherLocation(
              name: 'Worthing',
              state: 'Christ Church',
              country: 'BB',
              lat: 13.07,
              lon: -59.58,
            ),
          ],
          savedDashboards: {
            '13.0700,-59.5800': _dashboard(cityName: 'Worthing'),
          },
          mapLayerUrls: const {},
          onRefresh: () async {},
          onSearch: (_) {},
          onSelectLocation: (location) => selectedLocation = location,
          onSelectCurrentLocation: () async {
            currentLocationCount += 1;
          },
          onSwipeLocation: (location) => swipedLocation = location,
        ),
      ),
    );

    await tester.fling(
      find.byKey(const ValueKey('saved-location-page-view')),
      const Offset(-520, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(swipedLocation?.name, 'Worthing');
    _expectActiveDot(tester, 1, count: 2);

    await tester.tap(find.byTooltip('Search locations'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Speightstown, Saint Peter, BB'));
    await tester.pumpAndSettle();

    expect(selectedLocation?.name, 'Speightstown');
    expect(currentLocationCount, 0);
    _expectActiveDot(tester, 0, count: 2);
  });

  testWidgets('horizontal swipe pages through saved locations without wrapping',
      (
    tester,
  ) async {
    WeatherLocation? selectedLocation;
    WeatherLocation? swipedLocation;
    var currentLocationCount = 0;
    var refreshCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: WeatherDashboardShell(
          dashboard: _dashboard(),
          isLoading: false,
          isSearching: false,
          searchResults: const [],
          savedLocations: const [
            WeatherLocation(
              name: 'Worthing',
              state: 'Christ Church',
              country: 'BB',
              lat: 13.07,
              lon: -59.58,
            ),
            WeatherLocation(
              name: 'Oistins',
              state: 'Christ Church',
              country: 'BB',
              lat: 13.06,
              lon: -59.54,
            ),
          ],
          savedDashboards: {
            '13.0700,-59.5800': _dashboard(cityName: 'Worthing'),
            '13.0600,-59.5400': _dashboard(cityName: 'Oistins'),
          },
          mapLayerUrls: const {},
          onRefresh: () async {
            refreshCount += 1;
          },
          onSearch: (_) {},
          onSelectLocation: (location) => selectedLocation = location,
          onSelectCurrentLocation: () async {
            currentLocationCount += 1;
          },
          onSwipeLocation: (location) => swipedLocation = location,
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('location-carousel-floating-dots')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('saved-location-page-view')),
      findsOneWidget,
    );
    _expectActiveDot(tester, 0);

    await tester.fling(
      find.byKey(const ValueKey('saved-location-page-view')),
      const Offset(520, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(swipedLocation, isNull);
    expect(refreshCount, 0);
    expect(currentLocationCount, 0);
    _expectActiveDot(tester, 0);

    await tester.fling(
      find.byKey(const ValueKey('saved-location-page-view')),
      const Offset(-520, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(selectedLocation, isNull);
    expect(swipedLocation?.name, 'Worthing');
    expect(find.text('Worthing, BB'), findsOneWidget);
    _expectActiveDot(tester, 1);

    await tester.fling(
      find.byKey(const ValueKey('saved-location-page-view')),
      const Offset(-520, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(selectedLocation, isNull);
    expect(swipedLocation?.name, 'Oistins');
    expect(find.text('Oistins, BB'), findsOneWidget);
    _expectActiveDot(tester, 2);

    await tester.fling(
      find.byKey(const ValueKey('saved-location-page-view')),
      const Offset(-520, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(selectedLocation, isNull);
    expect(swipedLocation?.name, 'Oistins');
    _expectActiveDot(tester, 2);

    await tester.fling(
      find.byKey(const ValueKey('saved-location-page-view')),
      const Offset(520, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(selectedLocation, isNull);
    expect(swipedLocation?.name, 'Worthing');
    _expectActiveDot(tester, 1);

    await tester.fling(
      find.byKey(const ValueKey('saved-location-page-view')),
      const Offset(520, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(refreshCount, 0);
    expect(currentLocationCount, 1);
    _expectActiveDot(tester, 0);
  });

  test('weather theme changes background by condition', () {
    expect(
      WeatherTheme.gradientForCondition('clear sky').colors,
      isNot(WeatherTheme.gradientForCondition('light rain').colors),
    );
    expect(
      WeatherTheme.gradientForCondition('scattered clouds').colors,
      isNot(WeatherTheme.gradientForCondition('clear sky').colors),
    );
  });
}

double? _dotWidth(WidgetTester tester, int index) {
  return tester
      .getSize(find.byKey(ValueKey('location-carousel-dot-$index')))
      .width;
}

void _expectActiveDot(WidgetTester tester, int activeIndex, {int count = 3}) {
  final activeWidth = _dotWidth(tester, activeIndex)!;

  for (var index = 0; index < count; index += 1) {
    if (index == activeIndex) continue;
    expect(activeWidth, greaterThan(_dotWidth(tester, index)!));
  }
}

WeatherDashboard _dashboard({String cityName = 'Bridgetown'}) {
  return WeatherDashboard(
    weather: Weather(
      mainCondition: 'Clouds',
      description: 'scattered clouds',
      icon: '03d',
      temperature: 28.4,
      feelsLike: 31.2,
      tempMin: 26.5,
      tempMax: 30.1,
      pressure: 1012,
      humidity: 78,
      visibility: 10000,
      windSpeed: 6.4,
      cityName: cityName,
      sunrise: DateTime(2026, 7, 7, 5, 41),
      sunset: DateTime(2026, 7, 7, 18, 29),
      country: 'BB',
      coord: Coord(lon: -59.61, lat: 13.1),
    ),
    forecast: WeatherForecast(
      days: [
        ForecastDay(
          date: DateTime(2026, 7, 7),
          minTemp: 26.1,
          maxTemp: 31.2,
          description: 'Scattered clouds',
          icon: '03d',
        ),
      ],
      hourly: [
        ForecastHour(
          time: DateTime(2026, 7, 7, 9),
          temperature: 28.4,
          feelsLike: 31.2,
          precipitationChance: 0.42,
          description: 'Light rain',
          icon: '10d',
        ),
      ],
    ),
    airQuality: const AirQuality(
      index: 2,
      pm25: 4.7,
      pm10: 12.1,
      ozone: 34.2,
      nitrogenDioxide: 9.4,
    ),
  );
}
