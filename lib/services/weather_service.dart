import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/location_model.dart';

class WeatherService {
  static const String _weatherBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  Future<WeatherModel> getWeather(double latitude, double longitude) async {
    final uri = Uri.parse(_weatherBaseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherModel.fromJson(json);
    } else {
      throw Exception(
          'Gagal mengambil data cuaca. Status code: ${response.statusCode}');
    }
  }

  Future<List<LocationModel>> searchLocation(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_geocodingBaseUrl).replace(queryParameters: {
      'name': query.trim(),
      'count': '10',
      'language': 'id',
      'format': 'json',
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (!json.containsKey('results')) {
        return [];
      }

      final results = json['results'] as List;
      return results
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          'Gagal mencari lokasi. Status code: ${response.statusCode}');
    }
  }
}
