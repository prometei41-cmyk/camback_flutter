
import '../../../services/addresses_service.dart';
import '../../../services/fias_service.dart';
import '../../../services/map_addresses_service.dart';
import '../../../api/order_repository.dart';
import '../../../api/cart_repository.dart';
import '../../profile/models/address_model.dart';

class OrderController {
  final AddressService addressService;
  final OrderRepository orderRepository;
  final CartRepository cartRepository;

  OrderController({
    required this.addressService,
    required this.orderRepository,
    required this.cartRepository,
  });

  /// Создаёт новый адрес, если он изменён
  Future<AddressModel> ensureAddress({
    required String token,
    required AddressModel? oldAddress,
    required AddressModel newAddress,
  }) async {
    final isChanged = addressService.isAddressChanged(oldAddress, newAddress);

    if (!isChanged) return oldAddress!;

    return await addressService.createAddress(token, newAddress);
  }

  /// Создание заказа
  Future<Map<String, dynamic>> createOrder({
    required String token,
    required int addressId,
    required String comment,
    required String paymentMethod,
    required String deliveryTime,
    required String promoCode,
    required List<Map<String, dynamic>> items,
    required double totalPrice,
  }) async {
    return await orderRepository.createOrder(
      token,
      addressId: addressId,
      comment: comment,
      paymentMethod: paymentMethod,
      deliveryTime: deliveryTime,
      promoCode: promoCode,
      items: items,
      totalPrice: totalPrice,
    );
  }

  /// Очистка корзины
  Future<void> clearCart(String token) async {
    await cartRepository.clearCart(token);
  }

  Future<void> reorder(String token, List<dynamic> items) async {
    // Очистить корзину
    await cartRepository.clearCart(token);

    // Добавить товары из заказа
    for (final item in items) {
      final product = item["product"];
      final productId = product["id"];
      final qty = item["quantity"];

      await cartRepository.addToCart(token, productId, qty);
    }
  }

}
