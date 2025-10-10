class Coord {
  final double lon;
  final double lat;

  Coord({required this.lon, required this.lat});

  factory Coord.fromJson(Map<String, dynamic> json) {
    return Coord(
      lon: (json['lon']).toDouble(),
      lat: (json['lat']).toDouble(),
    );
  }
}

class Weather {
  final String mainCondition;
  final String description;
  final String icon;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final double pressure;
  final int humidity;
  final double windSpeed;
  final String cityName;
  final DateTime sunrise;
  final DateTime sunset;
  final String country;
  final Coord coord;

  Weather({
    required this.mainCondition,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.cityName,
    required this.sunrise,
    required this.sunset,
    required this.country,
    required this.coord,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      mainCondition: json['weather'][0]['main'] ?? '',
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      cityName: json['name'] ?? '',
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      tempMin: (json['main']['temp_min'] ?? 0).toDouble(),
      tempMax: (json['main']['temp_max'] ?? 0).toDouble(),
      pressure: (json['main']['pressure'] ?? 0).toDouble(),
      sunrise: json['sys']['sunrise'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000)
          : DateTime.now(),
      sunset: json['sys']['sunset'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000)
          : DateTime.now(),
      country: json['sys']['country'] ?? '',
      coord: json['coord'] != null
          ? Coord.fromJson(json['coord'])
          : Coord(lon: 0, lat: 0),
    );
  }
}
