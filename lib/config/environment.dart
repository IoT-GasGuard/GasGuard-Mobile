class Environment {
  static const bool production = true;

  static const String devBaseUrl = 'http://10.0.2.2:8080/api/v1';
  static const String prodBaseUrl = 'https://gasguard-api-282272338419.southamerica-west1.run.app/api/v1';

  static String get BASE_URL => production ? prodBaseUrl : devBaseUrl;
}