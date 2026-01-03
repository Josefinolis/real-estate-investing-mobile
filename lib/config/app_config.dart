class AppConfig {
  // Production server
  static const String apiBaseUrl = 'http://195.20.235.94/realstate/api';

  // Development URLs (uncomment as needed)
  // static const String apiBaseUrl = 'http://10.0.2.2:8080/api'; // Android emulator
  // static const String apiBaseUrl = 'http://localhost:8080/api'; // iOS simulator

  static const int defaultPageSize = 20;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
