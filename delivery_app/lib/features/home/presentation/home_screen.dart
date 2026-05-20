import 'package:delivery_app/features/home/presentation/widgets/category_item.dart';
import 'package:delivery_app/features/home/presentation/widgets/product_card.dart';
import 'package:delivery_app/features/home/presentation/widgets/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/auth_repository.dart';
import '../../../api/product_repository.dart';
import '../../../api/cart_repository.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../common/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? profile;
  List<dynamic> categories = [];
  List<dynamic> products = [];
  int? selectedCategoryId;
  bool isLoading = true;

  int cartCount = 0;

  final CartRepository cartRepository = CartRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCartCount();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access') ?? '';
  }

  Future<void> _loadData() async {
    try {
      final user = await AuthRepository().getProfile();
      final repo = ProductRepository();

      final cats = await repo.getCategories();
      final items = await repo.getProducts();

      setState(() {
        profile = user;
        categories = cats;
        products = items;
        isLoading = false;
      });
    } catch (e) {
      await AuthRepository().logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    final token = await _getToken();
    await cartRepository.addToCart(token, product['id'], 1);
    await _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    final token = await _getToken();
    final items = await cartRepository.getCart(token);

    int count = 0;
    for (final item in items) {
      count += item['quantity'] as int;
    }

    setState(() {
      cartCount = count;
    });
  }

  void _onCategoryTap(int id) {
    setState(() {
      selectedCategoryId = (selectedCategoryId == id) ? null : id;
    });
  }

  List<dynamic> get filteredProducts {
    if (selectedCategoryId == null) return products;
    return products.where((p) => p['category'] == selectedCategoryId).toList();
  }

  Future<void> _logout() async {
    await AuthRepository().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AppScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = (profile?['name'] ?? '').toString().trim();
    final email = (profile?['email'] ?? '').toString().trim();
    final displayName = name.isNotEmpty ? name : email;

    return AppScaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: AppText.h2("Кафе Камбэк"),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () async {
                  final updated = await Navigator.pushNamed(context, '/cart');
                  if (updated == true) {
                    _loadCartCount();
                  }
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: AppText.caption('$cartCount', color: Colors.white),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          // --- Приветствие ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppText.h2("Добро пожаловать, $displayName!"),
            ),
          ),

          // --- Категории ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppText.h2("Категории"),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: categories.map((cat) {
                  return CategoryItem(
                    title: cat['name'],
                    selected: selectedCategoryId == cat['id'],
                    onTap: () => _onCategoryTap(cat['id']),
                  );
                }).toList(),
              ),
            ),
          ),

          // --- Меню ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: AppText.h2("Меню"),
            ),
          ),

          // --- Список продуктов ---
          SliverList.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (_, i) {
              final p = filteredProducts[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ProductCard(
                  id: p['id'],
                  title: p['name'],
                  price: num.tryParse(p['price'].toString()) ?? 0,
                  weight: p['weight'],
                  image: p['image'],
                  description: p['description'],
                  badge: p['badge'],
                  onAdd: () => addToCart(p),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: p),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),

      bottom: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          if (index == 3) Navigator.pushNamed(context, '/profile');
          if (index == 2) {
            await Navigator.pushNamed(context, '/cart');
            _loadCartCount();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Меню',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
