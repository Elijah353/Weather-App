class AirQuality {
  const AirQuality({
    required this.index,
    required this.pm25,
    required this.pm10,
    required this.ozone,
    required this.nitrogenDioxide,
  });

  final int index;
  final double pm25;
  final double pm10;
  final double ozone;
  final double nitrogenDioxide;

  String get label {
    return switch (index) {
      1 => 'Good',
      2 => 'Fair',
      3 => 'Moderate',
      4 => 'Poor',
      5 => 'Very Poor',
      _ => 'Unavailable',
    };
  }

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final item = (json['list'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .firstOrNull;
    final main = item?['main'] as Map? ?? const {};
    final components = item?['components'] as Map? ?? const {};

    return AirQuality(
      index: main['aqi'] as int? ?? 0,
      pm25: (components['pm2_5'] ?? 0).toDouble(),
      pm10: (components['pm10'] ?? 0).toDouble(),
      ozone: (components['o3'] ?? 0).toDouble(),
      nitrogenDioxide: (components['no2'] ?? 0).toDouble(),
    );
  }
}
