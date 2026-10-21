/// Build-time configuration.
/// Override with: flutter run --dart-define=API_BASE_URL=https://staging.example/api/v1
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://app.dukanos.live/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
