import '../models/alert.dart';
import '../services/api_service.dart';

class AlertRepository {
  final ApiService _apiService;

  AlertRepository({required ApiService apiService}) : _apiService = apiService;

  Future<List<Alert>> getAlerts({bool activeOnly = false}) async {
    return _apiService.getAlerts(activeOnly: activeOnly);
  }

  Future<Alert> createAlert(Alert alert) async {
    return _apiService.createAlert(alert);
  }

  Future<Alert> updateAlert(String id, Alert alert) async {
    return _apiService.updateAlert(id, alert);
  }

  Future<void> deleteAlert(String id) async {
    return _apiService.deleteAlert(id);
  }
}
