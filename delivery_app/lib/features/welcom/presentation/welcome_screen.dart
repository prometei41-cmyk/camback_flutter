import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Импортируем наш новый класс AppText
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_tokens.dart'; // Также импортируем AppColors

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Ждем 3 секунды
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');
    final pin = prefs.getString('pin');

    // Устанавливаем флаг, что welcome показан (для совместимости)
    await prefs.setBool('welcome_shown', true);

    String nextRoute;
    if (token != null && pin != null) {
      nextRoute = '/pin';
    } else if (token != null) {
      // Пин-код обязателен, если токен есть, но пин нет - создаем
      nextRoute = '/create_pin';
    } else {
      nextRoute = '/login';
    }

    // Используем pushReplacementNamed, чтобы WelcomeScreen не оставался в стеке
    if (mounted) { // Проверяем, что виджет все еще в дереве
      Navigator.of(context).pushReplacementNamed(nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Убираем AppBar, так как у нас splash-экран
      // appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          // Используем градиент или цвет из AppColors
          gradient: LinearGradient(
            colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd], // Пример градиента
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          // Или просто цвет:
          // color: AppColors.primary,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип или название приложения
              // Используем AppText.h1 для заголовка
              AppText.h1(
                'FoodHub',
                color: Colors.white,
                textAlign: TextAlign.center,
                fontSize: 48, // Указываем нужный размер
                fontWeight: FontWeight.bold, // Указываем жирность
              ),
              const SizedBox(height: AppSpacing.lg), // Используем AppSpacing

              // Подзаголовок
              // Используем AppText.medium для подзаголовка
              AppText.medium(
                'Быстрая доставка вкусной еды',
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                textAlign: TextAlign.center,
                lineHeight: 1.5, // Опционально, если нужно настроить межстрочный интервал
              ),
              // Кнопка убрана - экран автоматически переходит через 3 секунды
            ],
          ),
        ),
      ),
    );
  }
}
