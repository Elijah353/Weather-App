class Geocoding {
  final String name;
  final double lat;
  final double lon;
  final String country;

  Geocoding({
    required this.name,
    required this.lat,
    required this.lon,
    required this.country,
  });

  factory Geocoding.fromJson(Map<String, dynamic> json) {
    return Geocoding(
      name: json['name'] ?? '',
      lat: (json['lat']).toDouble(),
      lon: (json['lon']).toDouble(),
      country: json['country'] ?? '',
    );
  }
}
