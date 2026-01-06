import '../models/scraper_config.dart';
import '../models/scraper_run.dart';
import '../services/api_service.dart';

class ScraperRepository {
  final ApiService _apiService;

  ScraperRepository({required ApiService apiService})
      : _apiService = apiService;

  Future<ScraperConfig> getConfig() async {
    return _apiService.getScraperConfig();
  }

  Future<ScraperConfig> updateConfig(ScraperConfigUpdate config) async {
    return _apiService.updateScraperConfig(config);
  }

  Future<ScraperRunList> getRunHistory({int page = 0, int size = 20}) async {
    return _apiService.getScraperRuns(page: page, size: size);
  }

  Future<ScraperRun?> getLastRun() async {
    return _apiService.getLastScraperRun();
  }

  Future<ScraperStatus> getStatus() async {
    return _apiService.getScraperStatus();
  }

  Future<Map<String, dynamic>> triggerRun() async {
    return _apiService.triggerScraperRun();
  }

  Future<List<String>> getAvailableCities() async {
    return _apiService.getAvailableCities();
  }

  Future<List<String>> getPropertyTypes() async {
    return _apiService.getPropertyTypes();
  }

  Future<List<Map<String, String>>> getFrequencies() async {
    return _apiService.getFrequencies();
  }
}
