import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorite_locations';
  static const String _lastLocationKey = 'last_selected_location';
  static const String _searchHistoryKey = 'search_history';

  Future<void> addFavorite(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    if (!favorites.any((fav) => fav.id == location.id)) {
      favorites.add(location);
      final jsonList = favorites.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_favoritesKey, jsonList);
    }
  }

  Future<void> removeFavorite(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((fav) => fav.id == location.id);
    final jsonList = favorites.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_favoritesKey, jsonList);
  }

  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_favoritesKey) ?? [];
    return jsonList
        .map((e) =>
            LocationModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isFavorite(LocationModel location) async {
    final favorites = await getFavorites();
    return favorites.any((fav) => fav.id == location.id);
  }

  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }

  Future<LocationModel?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_lastLocationKey);
    if (jsonString == null) return null;
    return LocationModel.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }

  Future<void> addSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_searchHistoryKey) ?? [];

    history.remove(query);
    history.insert(0, query);

    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await prefs.setStringList(_searchHistoryKey, history);
  }

  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }
}
