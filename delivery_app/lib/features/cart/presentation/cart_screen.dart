import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/api_client.dart';
import '../../../api/cart_repository.dart';
import '../../../core/theme/app_card.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/primary_button.dart';
import '../../order/presentation/order_screen.dart';
import '../../../common/app_scaffold.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartRepository cartRepository = CartRepository();
  bool cartChanged = false;

  List<dynamic> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access') ?? '';
  }

  Future<void> _loadCart() async {
    final token = await _getToken();
    final items = await cartRepository.getCart(token);

    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  double totalPrice() {
    double sum = 0;
    for (final item in cartItems) {
      final price = double.tryParse(item['product']['price'].toString()) ?? 0.0;
      final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      sum += price * quantity;
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  Future<void> _updateQuantity(int itemId, int newQty) async {
    final token = await _getToken();

    if (newQty < 1) {
      await cartRepository.removeItem(token, itemId);
    } else {
      await cartRepository.updateItem(token, itemId, newQty);
    }

    cartChanged = true;
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, cartChanged);
          },
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(
        child: Text(
          'Корзина пуста',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: cartItems.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, index) {
                  final item = cartItems[index];
                  final product = item['product'];

                  final qty =
                      int.tryParse(item['quantity'].toString()) ?? 0;
                  final price = double.tryParse(
                      product['price'].toString()) ??
                      0.0;

                  return AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(AppRadius.md),
                          child: Image.network(
                            '${ApiClient.baseUrl}${product['image']}',
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 72,
                              height: 72,
                              color: Colors.grey[300],
                              child: const Icon(Icons.fastfood,
                                  size: 32),
                            ),
                          ),
                        ),

                        const SizedBox(width: AppSpacing.md),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              AppText.h3(product['name']),
                              const SizedBox(height: AppSpacing.xs),
                              AppText.body(
                                '${price.toStringAsFixed(0)} ₽',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        _QuantityControl(
                          quantity: qty,
                          onIncrement: () =>
                              _updateQuantity(item['id'], qty + 1),
                          onDecrement: () =>
                              _updateQuantity(item['id'], qty - 1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.h3('Итого'),
                      AppText.h2('${totalPrice()} ₽'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    text: 'Оформить заказ',
                    fullWidth: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderScreen(
                            totalFromCart: totalPrice(),
                            items: cartItems,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityControl({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.remove,
          onTap: onDecrement,
        ),
        const SizedBox(width: AppSpacing.xs),
        AppText.body(quantity.toString()),
        const SizedBox(width: AppSpacing.xs),
        _CircleIconButton(
          icon: Icons.add,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
