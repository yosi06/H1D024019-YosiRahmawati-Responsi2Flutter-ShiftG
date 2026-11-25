class WeatherModel {
  final double latitude;
  final double longitude;
  final CurrentWeather current;
  final DailyForecast daily;

  WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      daily: DailyForecast.fromJson(json['daily'] as Map<String, dynamic>),
    );
  }
}

class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      relativeHumidity: (json['relative_humidity_2m'] as num).toInt(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}

class DailyForecast {
  final List<String> time;
  final List<double> temperatureMax;
  final List<double> temperatureMin;
  final List<int> precipitationProbabilityMax;
  final List<int> weatherCode;

  DailyForecast({
    required this.time,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      time: List<String>.from(json['time']),
      temperatureMax: (json['temperature_2m_max'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      temperatureMin: (json['temperature_2m_min'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      precipitationProbabilityMax:
          (json['precipitation_probability_max'] as List)
              .map((e) => (e as num).toInt())
              .toList(),
      weatherCode: (json['weather_code'] as List)
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }

  int get length => time.length;
}
