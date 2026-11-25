import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';
import '../services/weather_service.dart';
import '../services/local_storage_service.dart';

enum LoadingState { initial, loading, loaded, error, empty }

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocalStorageService _storageService = LocalStorageService();

  WeatherModel? _weather;
  LocationModel? _currentLocation;
  LoadingState _state = LoadingState.initial;
  String _errorMessage = '';
  bool _isFavorite = false;

  WeatherModel? get weather => _weather;
  LocationModel? get currentLocation => _currentLocation;
  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isFavorite => _isFavorite;

  Future<void> initialize() async {
    final lastLocation = await _storageService.getLastLocation();
    if (lastLocation != null) {
      await loadWeather(lastLocation);
    } else {
      final defaultLocation = LocationModel(
        id: 1642911,
        name: 'Jakarta',
        country: 'Indonesia',
        admin1: 'Jakarta',
        latitude: -6.2088,
        longitude: 106.8456,
      );
      await loadWeather(defaultLocation);
    }
  }

  Future<void> loadWeather(LocationModel location) async {
    _state = LoadingState.loading;
    _errorMessage = '';
    _currentLocation = location;
    notifyListeners();

    try {
      _weather = await _weatherService.getWeather(
        location.latitude,
        location.longitude,
      );
      _state = LoadingState.loaded;

      await _storageService.saveLastLocation(location);
      _isFavorite = await _storageService.isFavorite(location);
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Gagal memuat data cuaca.\nPeriksa koneksi internet Anda.';
      debugPrint('Error loading weather: $e');
    }

    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    if (_currentLocation == null) return;

    if (_isFavorite) {
      await _storageService.removeFavorite(_currentLocation!);
    } else {
      await _storageService.addFavorite(_currentLocation!);
    }

    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  Future<void> refreshWeather() async {
    if (_currentLocation != null) {
      await loadWeather(_currentLocation!);
    }
  }
}
