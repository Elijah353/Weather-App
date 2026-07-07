class WeatherForecast {
  const WeatherForecast({
    required this.days,
    this.hourly = const [],
  });

  final List<ForecastDay> days;
  final List<ForecastHour> hourly;

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final entries = (json['list'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final entry in entries) {
      final dateText = entry['dt_txt'] as String?;
      if (dateText == null || dateText.length < 10) continue;
      grouped.putIfAbsent(dateText.substring(0, 10), () => []).add(entry);
    }

    final days = grouped.entries.map((group) {
      final items = group.value;
      final representative = _representativeForecast(items);
      final weather = (representative['weather'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .firstOrNull;

      return ForecastDay(
        date: DateTime.parse(group.key),
        minTemp: items
            .map(
                (item) => ((item['main'] as Map?)?['temp_min'] ?? 0).toDouble())
            .reduce((a, b) => a < b ? a : b),
        maxTemp: items
            .map(
                (item) => ((item['main'] as Map?)?['temp_max'] ?? 0).toDouble())
            .reduce((a, b) => a > b ? a : b),
        description: _sentenceCase(weather?['description'] as String? ?? ''),
        icon: weather?['icon'] as String? ?? '',
      );
    }).toList();

    final hourly = entries.take(8).map((entry) {
      final main = (entry['main'] as Map?) ?? const {};
      final weather = (entry['weather'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .firstOrNull;

      return ForecastHour(
        time: DateTime.parse(entry['dt_txt'] as String),
        temperature: _temperature(main),
        feelsLike:
            ((main['feels_like'] ?? _temperature(main)) as num).toDouble(),
        precipitationChance: ((entry['pop'] ?? 0) as num).toDouble(),
        description: _sentenceCase(weather?['description'] as String? ?? ''),
        icon: weather?['icon'] as String? ?? '',
      );
    }).toList();

    return WeatherForecast(
      days: days.take(5).toList(),
      hourly: hourly,
    );
  }

  static double _temperature(Map<dynamic, dynamic> main) {
    final temp = main['temp'];
    if (temp is num) return temp.toDouble();

    final min = main['temp_min'];
    final max = main['temp_max'];
    if (min is num && max is num) {
      return ((min + max) / 2).toDouble();
    }

    return 0;
  }

  static Map<String, dynamic> _representativeForecast(
    List<Map<String, dynamic>> items,
  ) {
    return items.firstWhere(
      (item) => (item['dt_txt'] as String? ?? '').contains('12:00:00'),
      orElse: () => items[items.length ~/ 2],
    );
  }

  static String _sentenceCase(String value) {
    if (value.isEmpty) return 'Forecast unavailable';
    return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
  }
}

class ForecastDay {
  const ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.icon,
  });

  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String icon;
}

class ForecastHour {
  const ForecastHour({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.precipitationChance,
    required this.description,
    required this.icon,
  });

  final DateTime time;
  final double temperature;
  final double feelsLike;
  final double precipitationChance;
  final String description;
  final String icon;
}
