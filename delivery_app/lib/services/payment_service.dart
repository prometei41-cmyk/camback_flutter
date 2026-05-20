import '../config/environment.dart';

class PaymentService {
  /// Имитация платежа для разработки
  static Future<bool> processPayment({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required double amount,
  }) async {
    if (Environment.isProduction) {
      // Реальный платеж через Эватор
      return _realPaymentEvatoro(cardNumber, expiryDate, cvv, amount);
    } else {
      // Mock платеж для разработки
      return _mockPayment(cardNumber, amount);
    }
  }

  /// Mock платеж (для разработки)
  static Future<bool> _mockPayment(String cardNumber, double amount) async {
    // Имитация задержки
    await Future.delayed(const Duration(seconds: 2));

    // Если номер карты заканчивается на 4242 - платеж успешен
    // Если на 4444 - ошибка (тестовый номер)
    if (cardNumber.endsWith('4242')) {
      return true;
    } else if (cardNumber.endsWith('4444')) {
      throw Exception('Mock: Платеж отклонен');
    }

    return true; // По умолчанию успех
  }

  /// Реальный платеж через Эватор (для prod)
  static Future<bool> _realPaymentEvatoro(
      String cardNumber,
      String expiryDate,
      String cvv,
      double amount,
      ) async {
    // TODO: Когда получите ключи Эватора, добавить реальную интеграцию
    throw UnimplementedError('Платеж Эватор будет добавлен после получения ключей');
  }
}