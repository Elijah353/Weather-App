class UrlContainer {
  static const String currentWeather =
      'https://api.openweathermap.org/data/2.5/weather';
  static const String fiveDayForecast =
      'https://api.openweathermap.org/data/2.5/forecast';
  static const String airPollutionCurrent =
      'https://api.openweathermap.org/data/2.5/air_pollution';
  static const String airPollutionForecast =
      'https://api.openweathermap.org/data/2.5/air_pollution/forecast';
  static const String geocodingDirect =
      'https://api.openweathermap.org/geo/1.0/direct';
  static const String geocodingReverse =
      'https://api.openweathermap.org/geo/1.0/reverse';

  static const String weather = currentWeather;

  static String weatherMapTile(String layer, int z, int x, int y) {
    return 'https://tile.openweathermap.org/map/$layer/$z/$x/$y.png';
  }
}
