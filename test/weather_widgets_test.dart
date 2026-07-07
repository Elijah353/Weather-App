import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_test/data/model/weather_model.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/view/screens/weather/widgets/weather_metric_grid.dart';
import 'package:weather_test/view/screens/weather/widgets/weather_metric_tile.dart';
import 'package:weather_test/view/screens/weather/widgets/weather_summary_card.dart';
import 'package:weather_test/widgets/widgets.dart';

void main() {
  late Weather weather;

  setUp(() {
    weather = Weather(
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
      cityName: 'Bridgetown',
      sunrise: DateTime(2026, 7, 7, 5, 41),
      sunset: DateTime(2026, 7, 7, 18, 29),
      country: 'BB',
      coord: Coord(lon: -59.61, lat: 13.1),
    );
  });

  testWidgets('summary card presents current weather at a glance',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherSummaryCard(weather: weather),
        ),
      ),
    );

    expect(find.text('Bridgetown, BB'), findsOneWidget);
    expect(find.text('28°'), findsOneWidget);
    expect(find.text('Scattered clouds'), findsOneWidget);
    expect(find.text('Feels like'), findsOneWidget);
    expect(find.text('31°'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    expect(find.text('30°'), findsOneWidget);
    expect(find.text('27°'), findsOneWidget);
    expect(
        find.descendant(
          of: find.byType(WeatherSummaryCard),
          matching: find.byType(WeatherGlassCard),
        ),
        findsNothing);
  });

  testWidgets('metric grid shows titles and values without helper copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherMetricGrid(weather: weather),
        ),
      ),
    );

    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('78%'), findsOneWidget);
    expect(find.text('Wind'), findsOneWidget);
    expect(find.text('6.4 m/s'), findsOneWidget);
    expect(find.text('Pressure'), findsOneWidget);
    expect(find.text('1012 hPa'), findsOneWidget);
    expect(find.text('Visibility'), findsOneWidget);
    expect(find.text('10.0 km'), findsOneWidget);
    expect(find.text('Sunrise'), findsOneWidget);
    expect(find.text('05:41'), findsOneWidget);
    expect(find.text('Sunset'), findsOneWidget);
    expect(find.text('18:29'), findsOneWidget);
  });

  testWidgets(
      'metric grid shows enhanced humidity progress without value icons', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherMetricGrid(weather: weather),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('humidity-progress-bar')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('humidity-progress-fill')), findsOneWidget);
    expect(find.byKey(const ValueKey('wind-value-icon')), findsNothing);
    expect(find.byKey(const ValueKey('pressure-value-icon')), findsNothing);
    expect(find.text('6.4 m/s'), findsOneWidget);
    expect(find.text('1012 hPa'), findsOneWidget);
  });

  testWidgets('metric grid uses visual dashboard cards without detail copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherMetricGrid(weather: weather),
        ),
      ),
    );

    expect(find.text('Similar to yesterday'), findsNothing);
    expect(find.text("It's windy"), findsNothing);
    expect(find.text('Currently steady'), findsNothing);
    expect(find.text('First light'), findsNothing);
    expect(find.text('Evening light'), findsNothing);
    expect(find.byKey(const ValueKey('wind-direction-gauge')), findsOneWidget);
    expect(find.byKey(const ValueKey('pressure-arc-gauge')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('visibility-range-visual')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('sunrise-horizon-visual')), findsOneWidget);
    expect(find.byKey(const ValueKey('sunset-horizon-visual')), findsOneWidget);
  });

  testWidgets('metric dashboard cards stay compact on the home page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherMetricGrid(weather: weather),
        ),
      ),
    );

    final humidityCardSize = tester.getSize(
      find.byType(WeatherMetricTile).at(0),
    );

    for (var index = 1; index < 6; index += 1) {
      final cardSize = tester.getSize(find.byType(WeatherMetricTile).at(index));
      expect(cardSize.height, humidityCardSize.height);
    }
  });

  testWidgets('metric icons avoid dark accents on glass cards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherMetricGrid(weather: weather),
        ),
      ),
    );

    final pressureIcon = tester.widget<Icon>(find.byIcon(Icons.speed_rounded));
    final sunsetIcon = tester.widget<Icon>(find.byIcon(Icons.nightlight_round));
    final windIcon = tester.widget<Icon>(find.byIcon(Icons.air_rounded).first);

    expect(pressureIcon.color, isNot(WeatherTheme.deepSky));
    expect(sunsetIcon.color, isNot(WeatherTheme.twilight));
    expect(windIcon.color, WeatherTheme.rainAccent);
  });

  testWidgets('secondary temperature details avoid low contrast blue text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherSummaryCard(weather: weather),
        ),
      ),
    );

    final highText = tester.widget<Text>(find.text('30°'));
    final lowText = tester.widget<Text>(find.text('27°'));

    expect(highText.style?.color, WeatherTheme.onGlassPrimary);
    expect(lowText.style?.color, WeatherTheme.onGlassPrimary);
  });

  testWidgets('shared weather cards use a light transparent glass surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeatherGlassCard(child: Text('Card body')),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(WeatherGlassCard),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    final surfaceColor = decoration.color!;

    expect(surfaceColor.r, lessThan(WeatherTheme.card.r));
    expect(surfaceColor.g, lessThan(WeatherTheme.card.g));
    expect(surfaceColor.b, lessThan(WeatherTheme.card.b));
    expect(surfaceColor.a, lessThanOrEqualTo(0.3));
    expect(decoration.border, isNull);
  });
}
