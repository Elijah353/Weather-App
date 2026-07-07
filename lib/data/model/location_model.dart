class WeatherLocation {
  const WeatherLocation({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    this.state,
  });

  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;

  String get displayName {
    final parts = [
      name,
      if (state != null && state!.isNotEmpty) state,
      country,
    ];
    return parts.join(', ');
  }

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    return WeatherLocation(
      name: json['name'] as String? ?? 'Unknown location',
      state: json['state'] as String?,
      country: json['country'] as String? ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lon: (json['lon'] ?? 0).toDouble(),
    );
  }

  static List<WeatherLocation> listFromJson(dynamic json) {
    return (json as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(WeatherLocation.fromJson)
        .toList();
  }
}
