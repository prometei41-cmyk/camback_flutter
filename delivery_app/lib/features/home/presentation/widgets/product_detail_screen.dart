import 'package:delivery_app/common/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../api/cart_repository.dart';
import '../../../../api/product_repository.dart';
import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart'; // Импортируем AppColors
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/primary_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int? productId;
  final Map<String, dynamic>? product;

  const ProductDetailsScreen({
    super.key,
    this.productId,
    this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Map<String, dynamic>? _productData; // Имя изменено для ясности
  bool _isLoading = true;
  final CartRepository _cartRepo = CartRepository();
  final ProductRepository _productRepo = ProductRepository(); // Используем для загрузки продукта

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() { _isLoading = true; });
    // Используем вспомогательную функцию для загрузки данных
    _productData = await _fetchProductData();
    setState(() { _isLoading = false; });
  }

  // Вспомогательная функция для загрузки данных продукта
  Future<Map<String, dynamic>?> _fetchProductData() async {
    if (widget.product != null) {
      // Если продукт передан напрямую, используем его
      return widget.product;
    } else if (widget.productId != null) {
      // Если передан только ID, загружаем с помощью репозитория
      try {
        final response = await _productRepo.getProductById(widget.productId!);
        if (response['success'] == true && response['data'] != null) {
          // Убедимся, что 'data' действительно Map<String, dynamic>
          if (response['data'] is Map<String, dynamic>) {
            return response['data'] as Map<String, dynamic>;
          } else {
            print('Received product data is not a Map<String, dynamic>');
            return null;
          }
        } else {
          print('Failed to load product by ID: ${response['message']}');
          return null;
        }
      } catch (e) {
        print('Error loading product by ID: $e');
        return null;
      }
    }
    return null; // Возвращаем null, если нет ни продукта, ни ID
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: 'Детали продукта',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _productData == null
          ? const Center(child: Text('Продукт не найден', style: TextStyle(fontSize: 18)))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Изображение продукта
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppCard.borderRadius)),
              child: Image.network(
                _productData!['image'] ?? '', // Используем пустую строку, если image null
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название продукта и ярлык
                  Row(
                    children: [
                      Expanded(
                        child: AppText.bold(
                          _productData!['name'] ?? 'Без названия',
                          fontSize: 24,
                        ),
                      ),
                      // Отображение ярлыка (badge)
                      if (_productData!['badge'] != null && _productData!['badge'] != 'none')
                        _buildBadge(_productData!['badge']),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Категория
                  if (_productData!['category'] != null && _productData!['category']['name'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppText.medium(
                        _productData!['category']['name'],
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                  // Цена
                  AppText.medium(
                    '${num.parse(_productData!['price'].toString()).toStringAsFixed(0)} ₽',
                    fontSize: 22,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Вес
                  _buildProductInfoSection(
                    'Вес',
                    _productData!['weight']?.toString() ?? '',
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),

                  // Калории
                  _buildProductInfoSection(
                    'Калории',
                    _productData!['calories']?.toString() ?? '',
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),

                  // Описание
                  _buildProductInfoSection(
                    'Описание',
                    _productData!['description'] ?? '',
                    fontSize: 15,
                    color: Colors.grey[800],
                    lineHeight: 1.6,
                  ),

                  // Аллергены
                  _buildProductInfoSection(
                    'Содержит аллергены:',
                    _productData!['allergens'] ?? '',
                    fontSize: 15,
                    color: Colors.red[700],
                    lineHeight: 1.6,
                  ),
                ],
              ),
            ),
            // Кнопка "Добавить"
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: PrimaryButton.fullWidth(
                text: 'Добавить в корзину',
                onTap: () => _addToCart(context), // Вызываем метод для добавления в корзину
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Виджет для отображения ярлыка (badge)
  Widget _buildBadge(String badge) {
    Color badgeColor;
    switch (badge.toLowerCase()) {
      case 'new':
        badgeColor = Colors.green.shade600;
        break;
      case 'hit':
        badgeColor = Colors.orange.shade700;
        break;
      case 'sale':
        badgeColor = Colors.red.shade700;
        break;
      default:
        badgeColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: AppText.bold(
        badge.toUpperCase(),
        fontSize: 12,
        color: Colors.white,
      ),
    );
  }

  // Вспомогательный виджет для секций информации о продукте (вес, калории, описание, аллергены)
  Widget _buildProductInfoSection(String title, String content, {Color? color, double fontSize = 14, double? lineHeight}) {
    // Не отображаем секцию, если контент пустой
    if (content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bold(title, fontSize: fontSize + 2), // Заголовок секции
          const SizedBox(height: AppSpacing.xs),
          AppText.medium(
            content,
            fontSize: fontSize,
            color: color ?? Colors.grey[700],
            lineHeight: lineHeight,
          ),
        ],
      ),
    );
  }

  // Метод для добавления товара в корзину
  void _addToCart(BuildContext context) async {
    try {
      // Получаем ID продукта из _productData
      final productId = _productData?['id'];
      if (productId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: ID продукта не найден.')),
        );
        return;
      }

      // Получаем токен авторизации пользователя
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token'); // Убедитесь, что ключ 'user_token' совпадает с вашим

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: Пользователь не авторизован.')),
        );
        // Здесь можно добавить логику перенаправления на экран входа
        // Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // Отправляем запрос на добавление в корзину
      final response = await _cartRepo.addToCart({'product_id': productId, 'quantity': 1}, token);

      // Обрабатываем ответ сервера
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Товар добавлен в корзину!')),
        );
        // Здесь можно обновить UI, например, обновить счетчик товаров в корзине
        // (для этого может потребоваться механизм управления состоянием, например, Provider или BLoC)
      } else {
        // Показываем сообщение об ошибке от сервера
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Ошибка при добавлении в корзину')),
        );
      }
    } catch (e) {
      // Обработка ошибок сети или других исключений
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Произошла ошибка: $e')),
      );
    }
  }
}
