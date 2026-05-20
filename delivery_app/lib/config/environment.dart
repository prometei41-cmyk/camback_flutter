class Environment {
  static const String apiBaseUrl = 'http://192.168.0.154:8000';

  // Флаг для разработки
  static const bool isProduction = false;  // Измените на true перед релизом

  // Ключи Эватора
  static const String evatorPublicKey = isProduction
      ? 'prod_key_here'  // Получите при размещении
      : 'mock_key_dev';   // Mock для разработки
}