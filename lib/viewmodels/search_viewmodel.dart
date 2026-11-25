import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/weather_service.dart';
import '../services/local_storage_service.dart';

enum SearchState { initial, loading, loaded, error, empty }

class SearchViewModel extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocalStorageService _storageService = LocalStorageService();

  List<LocationModel> _searchResults = [];
  List<LocationModel> _favorites = [];
  List<String> _searchHistory = [];
  SearchState _state = SearchState.initial;
  String _errorMessage = '';
  String _query = '';

  List<LocationModel> get searchResults => _searchResults;
  List<LocationModel> get favorites => _favorites;
  List<String> get searchHistory => _searchHistory;
  SearchState get state => _state;
  String get errorMessage => _errorMessage;
  String get query => _query;

  Future<void> initialize() async {
    _favorites = await _storageService.getFavorites();
    _searchHistory = await _storageService.getSearchHistory();
    notifyListeners();
  }

  Future<void> searchLocation(String query) async {
    _query = query.trim();

    if (_query.isEmpty) {
      _searchResults = [];
      _state = SearchState.initial;
      notifyListeners();
      return;
    }

    _state = SearchState.loading;
    notifyListeners();

    try {
      _searchResults = await _weatherService.searchLocation(_query);

      if (_searchResults.isEmpty) {
        _state = SearchState.empty;
      } else {
        _state = SearchState.loaded;
      }

      await _storageService.addSearchHistory(_query);
      _searchHistory = await _storageService.getSearchHistory();
    } catch (e) {
      _state = SearchState.error;
      _errorMessage = 'Gagal mencari lokasi.\nPeriksa koneksi internet Anda.';
      debugPrint('Error searching location: $e');
    }

    notifyListeners();
  }

  Future<void> removeFavorite(LocationModel location) async {
    await _storageService.removeFavorite(location);
    _favorites = await _storageService.getFavorites();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storageService.clearSearchHistory();
    _searchHistory = [];
    notifyListeners();
  }

  Future<void> reloadFavorites() async {
    _favorites = await _storageService.getFavorites();
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _state = SearchState.initial;
    _query = '';
    notifyListeners();
  }
}
