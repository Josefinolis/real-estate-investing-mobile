import '../models/property.dart';
import '../models/search_filter.dart';
import '../models/price_history.dart';
import '../services/api_service.dart';

class PropertyRepository {
  final ApiService _apiService;

  PropertyRepository({required ApiService apiService})
      : _apiService = apiService;

  Future<PropertyList> searchProperties(SearchFilter filter) async {
    return _apiService.searchProperties(filter.toQueryParams());
  }

  Future<Property> getProperty(String id) async {
    return _apiService.getProperty(id);
  }

  Future<List<PriceHistory>> getPriceHistory(String propertyId) async {
    return _apiService.getPriceHistory(propertyId);
  }
}
