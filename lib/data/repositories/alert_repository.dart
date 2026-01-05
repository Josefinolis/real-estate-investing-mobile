import 'package:flutter/foundation.dart';
import '../models/alert.dart';
import '../services/api_service.dart';

class AlertRepository {
  final ApiService _apiService;

  // Local cache for demo/offline mode
  final List<Alert> _localAlerts = [];
  int _localIdCounter = 1;

  AlertRepository({required ApiService apiService}) : _apiService = apiService;

  Future<List<Alert>> getAlerts({bool activeOnly = false}) async {
    try {
      final alerts = await _apiService.getAlerts(activeOnly: activeOnly);
      return alerts;
    } catch (e) {
      debugPrint('⚠️ [ALERT_REPO] Error fetching alerts: $e');
      // Return local alerts if API fails (demo/offline mode)
      if (activeOnly) {
        return _localAlerts.where((a) => a.isActive).toList();
      }
      return List.from(_localAlerts);
    }
  }

  Future<Alert> createAlert(Alert alert) async {
    try {
      return await _apiService.createAlert(alert);
    } catch (e) {
      debugPrint('⚠️ [ALERT_REPO] Error creating alert: $e');
      // Create locally if API fails
      final localAlert = alert.copyWith(
        id: 'local_${_localIdCounter++}',
        createdAt: DateTime.now(),
      );
      _localAlerts.insert(0, localAlert);
      return localAlert;
    }
  }

  Future<Alert> updateAlert(String id, Alert alert) async {
    try {
      return await _apiService.updateAlert(id, alert);
    } catch (e) {
      debugPrint('⚠️ [ALERT_REPO] Error updating alert: $e');
      // Update locally if API fails
      final index = _localAlerts.indexWhere((a) => a.id == id);
      if (index != -1) {
        _localAlerts[index] = alert.copyWith(id: id);
        return _localAlerts[index];
      }
      return alert.copyWith(id: id);
    }
  }

  Future<void> deleteAlert(String id) async {
    try {
      await _apiService.deleteAlert(id);
    } catch (e) {
      debugPrint('⚠️ [ALERT_REPO] Error deleting alert: $e');
    }
    // Always remove from local cache
    _localAlerts.removeWhere((a) => a.id == id);
  }
}
