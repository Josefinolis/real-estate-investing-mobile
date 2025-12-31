import '../models/favorite.dart';
import '../services/api_service.dart';

class FavoriteRepository {
  final ApiService _apiService;

  FavoriteRepository({required ApiService apiService})
      : _apiService = apiService;

  Future<List<Favorite>> getFavorites() async {
    return _apiService.getFavorites();
  }

  Future<Favorite> addFavorite(String propertyId, {String? notes}) async {
    return _apiService.addFavorite(propertyId, notes: notes);
  }

  Future<void> removeFavorite(String propertyId) async {
    return _apiService.removeFavorite(propertyId);
  }

  Future<bool> checkFavorite(String propertyId) async {
    return _apiService.checkFavorite(propertyId);
  }
}
