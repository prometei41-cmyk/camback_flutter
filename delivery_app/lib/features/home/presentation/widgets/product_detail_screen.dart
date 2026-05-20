import 'package:delivery_app/common/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../api/cart_repository.dart';
import '../../../../api/product_repository.dart';
import '../../../../core/theme/app_card.dart';
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
  Map<String, dynamic>? product;
  bool isLoading = true;
  final cartRepo = CartRepository();

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    if (widget.product != null) {
      setState(() {
        product = widget.product;
        isLoading = false;
      });
      return;
    }

    final repo = ProductRepository();
    final data = await repo.getProduct(widget.productId!);

    setState(() {
      product = data;
      isLoading = false;
    });
  }

  Future<void> _addToCart() async {
    final token = await _getToken();

    await cartRepo.addToCart(
      token,
      product!['id'],
      1,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Добавлено в корзину")),
    );
  }


  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access') ?? '';
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading || product == null) {
      return const AppScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text(product!['name']),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // --- IMAGE ---
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Image.network(
              product!['image'],
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 240,
                color: Colors.grey.shade200,
                child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- TITLE + BADGE ---
          Row(
            children: [
              Expanded(
                child: AppText.h2(product!['name']),
              ),
              if (product!['badge'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText.caption(
                    product!['badge'],
                    color: Colors.white,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // --- PRICE + WEIGHT ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.h2(
                "${product!['price']} ₽",
                color: Theme.of(context).colorScheme.primary,
              ),
              AppText.body(
                product!['weight'] ?? "",
                color: Colors.black54,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- DESCRIPTION ---
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h3("Описание"),
                const SizedBox(height: AppSpacing.sm),
                AppText.body(
                  product!['description'] ?? "Описание отсутствует",
                  color: Colors.black87,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),

      bottom: PrimaryButton(
        text: "Добавить в корзину",
        onTap: _addToCart,
        ),
    );
  }
}
