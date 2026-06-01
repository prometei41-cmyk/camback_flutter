import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета
  static const Color primary = Color(0xFFF9616E); // Пример основного цвета
  static const Color secondary = Color(0xFF1E88E5); // Пример вторичного цвета
  static const Color accent = Color(0xFFFFC107); // Пример акцентного цвета

  // Цвета для текста
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textLight = Colors.white;

  // Цвета для фона
  static const Color background = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF5F5F5); // Светло-серый фон

  // Цвета для состояний
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;

  // --- Новые цвета для градиента ---
  // Эти цвета - просто примеры. Выберите те, которые вам больше нравятся.
  static const Color primaryGradientStart = Color(0xFFF9616E); // Начинается с основного цвета
  static const Color primaryGradientEnd = Color(0xFFFF979F);   // Более светлый оттенок основного цвета
  // Если хотите другой градиент:
  // static const Color primaryGradientStart = Color(0xFF4CAF50); // Зеленый
  // static const Color primaryGradientEnd = Color(0xFF81C784);   // Светло-зеленый

  // Дополнительные цвета, если нужны
  static const Color greyLight = Color(0xFFEEEEEE);
  static const Color greyMedium = Color(0xFFBDBDBD);
  static const Color greyDark = Color(0xFF616161);

  // Пример определения цвета для кнопки
  static Color getPrimaryButtonColor(BuildContext context) {
    // Можно возвращать AppColors.primary или что-то другое в зависимости от темы
    return primary;
  }
}

class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}
