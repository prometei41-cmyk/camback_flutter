import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для MethodChannel, если понадобится
import 'package:flutter_svg/flutter_svg.dart'; // Если используете SVG иконки

import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart'; // Импортируем AppColors
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/primary_button.dart';

class ProductCard extends StatelessWidget {
  final int id;
  final String title;
  final num price;
  final String weight; // Вес продукта
  final String image; // URL изображения продукта
  final String description; // Полное описание продукта
  final String? badge; // Ярлык продукта (например, "New", "Sale", "Hit")
  final VoidCallback onAdd; // Действие при нажатии кнопки "Добавить"
  final VoidCallback? onTap; // Действие при нажатии на всю карточку (например, переход к деталям)

  const ProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    required this.weight,
    required this.image,
    required this.description,
    required this.badge,
    required this.onAdd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: EdgeInsets.zero, // Убираем padding, чтобы изображение занимало всю ширину
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              // Изображение продукта
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppCard.borderRadius)),
                child: Image.network(
                  image,
                  height: 180, // Фиксированная высота для изображения
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container( // Заглушка при ошибке загрузки
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              // Отображение ярлыка (badge), если он есть и не 'none'
              if (badge != null && badge != 'none')
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getBadgeColor(badge!), // Функция для получения цвета ярлыка
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AppText.bold(
                      badge!.toUpperCase(), // Ярлык большими буквами
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          // Информация о продукте (название, цена, вес)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold(title, fontSize: 16),
                const SizedBox(height: AppSpacing.sm),
                AppText.medium(
                  '${price.toStringAsFixed(0)} ₽', // Цена как целое число с символом рубля
                  fontSize: 18,
                  color: AppColors.primary, // Используем основной цвет темы
                ),
                const SizedBox(height: AppSpacing.xs),
                // Отображаем вес, если он есть
                if (weight.isNotEmpty)
                  AppText.medium(
                    weight,
                    fontSize: 12,
                    color: Colors.grey[600], // Серый цвет для веса
                  ),
              ],
            ),
          ),
          // Кнопка "Добавить"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, bottom: AppSpacing.md),
            child: PrimaryButton.fullWidth(
              text: 'Добавить',
              onTap: onAdd,
            ),
          ),
        ],
      ),
    );
  }

  // Функция для определения цвета ярлыка в зависимости от его значения
  Color _getBadgeColor(String badge) {
    switch (badge) {
      case 'new':
        return Colors.green.shade600; // Более насыщенный зеленый
      case 'hit':
        return Colors.orange.shade700; // Более насыщенный оранжевый
      case 'sale':
        return Colors.red.shade700; // Более насыщенный красный
      default:
        return AppColors.primary; // Цвет по умолчанию (основной цвет темы)
    }
  }
}
