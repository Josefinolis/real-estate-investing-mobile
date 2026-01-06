import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/property.dart';
import '../models/alert.dart';
import '../models/favorite.dart';
import '../models/price_history.dart';
import '../models/user.dart';
import '../models/scraper_config.dart';
import '../models/scraper_run.dart';
import '../../config/app_config.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;
  final bool firebaseAvailable;

  ApiService({required this.baseUrl, this.firebaseAvailable = true})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: AppConfig.connectionTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
          },
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (firebaseAvailable) {
          try {
            final user = firebase_auth.FirebaseAuth.instance.currentUser;
            if (user != null) {
              options.headers['X-Firebase-UID'] = user.uid;
            }
          } catch (e) {
            // Firebase not available, continue without auth header
          }
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle errors globally
        return handler.next(error);
      },
    ));
  }

  // Auth
  Future<User> registerUser(String firebaseUid, String email) async {
    final response = await _dio.post('/auth/register', data: {
      'firebaseUid': firebaseUid,
      'email': email,
    });
    return User.fromJson(response.data);
  }

  Future<void> updateFcmToken(String fcmToken) async {
    await _dio.post('/auth/fcm-token', data: {
      'fcmToken': fcmToken,
    });
  }

  Future<User> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return User.fromJson(response.data);
  }

  // Properties
  Future<PropertyList> searchProperties(Map<String, dynamic> params) async {
    final response = await _dio.get('/properties', queryParameters: params);
    return PropertyList.fromJson(response.data);
  }

  Future<Property> getProperty(String id) async {
    final response = await _dio.get('/properties/$id');
    return Property.fromJson(response.data['property']);
  }

  Future<List<PriceHistory>> getPriceHistory(String propertyId) async {
    final response = await _dio.get('/properties/$propertyId/price-history');
    return (response.data as List)
        .map((e) => PriceHistory.fromJson(e))
        .toList();
  }

  // Alerts
  Future<List<Alert>> getAlerts({bool activeOnly = false}) async {
    final response = await _dio.get('/alerts', queryParameters: {
      'activeOnly': activeOnly.toString(),
    });
    return (response.data as List).map((e) => Alert.fromJson(e)).toList();
  }

  Future<Alert> createAlert(Alert alert) async {
    final response = await _dio.post('/alerts', data: alert.toJson());
    return Alert.fromJson(response.data);
  }

  Future<Alert> updateAlert(String id, Alert alert) async {
    final response = await _dio.put('/alerts/$id', data: alert.toJson());
    return Alert.fromJson(response.data);
  }

  Future<void> deleteAlert(String id) async {
    await _dio.delete('/alerts/$id');
  }

  // Favorites
  Future<List<Favorite>> getFavorites() async {
    final response = await _dio.get('/favorites');
    return (response.data as List).map((e) => Favorite.fromJson(e)).toList();
  }

  Future<Favorite> addFavorite(String propertyId, {String? notes}) async {
    final response = await _dio.post('/favorites', data: {
      'propertyId': propertyId,
      if (notes != null) 'notes': notes,
    });
    return Favorite.fromJson(response.data);
  }

  Future<void> removeFavorite(String propertyId) async {
    await _dio.delete('/favorites/$propertyId');
  }

  Future<bool> checkFavorite(String propertyId) async {
    final response = await _dio.get('/favorites/check/$propertyId');
    return response.data['isFavorite'] as bool;
  }

  // Scraper
  Future<ScraperConfig> getScraperConfig() async {
    final response = await _dio.get('/scraper/config');
    return ScraperConfig.fromJson(response.data);
  }

  Future<ScraperConfig> updateScraperConfig(ScraperConfigUpdate config) async {
    final response = await _dio.put('/scraper/config', data: config.toJson());
    return ScraperConfig.fromJson(response.data);
  }

  Future<ScraperRunList> getScraperRuns({int page = 0, int size = 20}) async {
    final response = await _dio.get('/scraper/runs', queryParameters: {
      'page': page,
      'size': size,
    });
    return ScraperRunList.fromJson(response.data);
  }

  Future<ScraperRun?> getLastScraperRun() async {
    final response = await _dio.get('/scraper/runs/last');
    if (response.data == null) return null;
    return ScraperRun.fromJson(response.data);
  }

  Future<ScraperStatus> getScraperStatus() async {
    final response = await _dio.get('/scraper/status');
    return ScraperStatus.fromJson(response.data);
  }

  Future<Map<String, dynamic>> triggerScraperRun() async {
    final response = await _dio.post('/scraper/run');
    return response.data as Map<String, dynamic>;
  }

  Future<List<String>> getAvailableCities() async {
    final response = await _dio.get('/scraper/cities');
    return (response.data as List<dynamic>).map((e) => e as String).toList();
  }

  Future<List<String>> getPropertyTypes() async {
    final response = await _dio.get('/scraper/property-types');
    return (response.data as List<dynamic>).map((e) => e as String).toList();
  }

  Future<List<Map<String, String>>> getFrequencies() async {
    final response = await _dio.get('/scraper/frequencies');
    return (response.data as List<dynamic>)
        .map((e) => Map<String, String>.from(e as Map))
        .toList();
  }
}
