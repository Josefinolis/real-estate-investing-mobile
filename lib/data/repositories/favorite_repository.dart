import 'package:flutter/foundation.dart';
import '../models/favorite.dart';
import '../services/api_service.dart';

class FavoriteRepository {
  final ApiService _apiService;

  // Local cache for demo/offline mode
  final List<Favorite> _localFavorites = [];
  int _localIdCounter = 1;

  FavoriteRepository({required ApiService apiService}) : _apiService = apiService;

  Future<List<Favorite>> getFavorites() async {
    try {
      final favorites = await _apiService.getFavorites();
      return favorites;
    } catch (e) {
      debugPrint('⚠️ [FAVORITE_REPO] Error fetching favorites: $e');
      // Return local favorites if API fails (demo/offline mode)
      return List.from(_localFavorites);
    }
  }

  Future<Favorite> addFavorite(String propertyId, {String? notes}) async {
    try {
      return await _apiService.addFavorite(propertyId, notes: notes);
    } catch (e) {
      debugPrint('⚠️ [FAVORITE_REPO] Error adding favorite: $e');
      // Create locally if API fails
      final localFavorite = Favorite(
        id: 'local_${_localIdCounter++}',
        propertyId: propertyId,
        notes: notes,
        createdAt: DateTime.now(),
      );
      _localFavorites.insert(0, localFavorite);
      return localFavorite;
    }
  }

  Future<void> removeFavorite(String propertyId) async {
    try {
      await _apiService.removeFavorite(propertyId);
    } catch (e) {
      debugPrint('⚠️ [FAVORITE_REPO] Error removing favorite: $e');
    }
    // Always remove from local cache
    _localFavorites.removeWhere((f) => f.propertyId == propertyId);
  }

  Future<bool> checkFavorite(String propertyId) async {
    try {
      return await _apiService.checkFavorite(propertyId);
    } catch (e) {
      debugPrint('⚠️ [FAVORITE_REPO] Error checking favorite: $e');
      // Check local cache if API fails
      return _localFavorites.any((f) => f.propertyId == propertyId);
    }
  }
}
