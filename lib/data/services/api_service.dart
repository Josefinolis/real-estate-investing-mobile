import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/property.dart';
import '../models/alert.dart';
import '../models/favorite.dart';
import '../models/price_history.dart';
import '../models/user.dart';
import '../../config/app_config.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService({required this.baseUrl})
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
        final user = firebase_auth.FirebaseAuth.instance.currentUser;
        if (user != null) {
          options.headers['X-Firebase-UID'] = user.uid;
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
}
