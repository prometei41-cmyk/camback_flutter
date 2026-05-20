import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../common/app_scaffold.dart';
import '../../../api/cart_repository.dart';
import '../../../api/order_repository.dart';

import '../../../core/theme/app_card.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/primary_button.dart';
import '../../../services/addresses_service.dart';
import '../../../services/fias_service.dart';
import '../../../services/map_addresses_service.dart';

import '../../../ui/app_text_field.dart';
import '../../profile/models/address_model.dart';
import '../../addresses/address_picker_sheet.dart';
import '../logic/order_controller.dart';
import 'order_success_screen.dart';
import 'map_screen.dart';


class OrderScreen extends StatefulWidget {
  final List<dynamic> items;
  final double totalFromCart;

  const OrderScreen({
    super.key,
    required this.items,
    required this.totalFromCart,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // --- Services & Controller ---
  late final AddressService addressService;
  late final FiasService fiasService;
  late final MapAddressService mapAddressService;
  late final OrderController controller;

  AddressModel? selectedAddress;
  int? selectedAddressId;

  bool isAddressLoading = true;

  // --- Controllers ---
  final streetController = TextEditingController();
  final houseController = TextEditingController();
  final corpusController = TextEditingController();
  final entranceController = TextEditingController();
  final floorController = TextEditingController();
  final flatController = TextEditingController();
  final commentController = TextEditingController();
  final promoController = TextEditingController();

  // --- Suggestions ---
  List<Map<String, dynamic>> streetSuggestions = [];
  List<String> houseSuggestions = [];
  List<String> entranceSuggestions = [];

  bool isSearchingStreet = false;

  // --- Delivery ---
  String deliveryTime = 'asap';
  String? selectedInterval;
  String? intervalError;

  // --- Payment ---
  String paymentMethod = 'card';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    addressService = AddressService();
    fiasService = FiasService();
    mapAddressService = MapAddressService();

    controller = OrderController(
      addressService: addressService,
      orderRepository: OrderRepository(),
      cartRepository: CartRepository(),
    );

    _loadDefaultAddress();
  }

  @override
  void dispose() {
    streetController.dispose();
    houseController.dispose();
    corpusController.dispose();
    entranceController.dispose();
    floorController.dispose();
    flatController.dispose();
    commentController.dispose();
    promoController.dispose();
    super.dispose();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access') ?? '';
  }

  // ------------------ LOAD DEFAULT ADDRESS ------------------
  Future<void> _loadDefaultAddress() async {
    final token = await _getToken();

    try {
      final addresses = await addressService.loadAddresses(token);

      if (addresses.isEmpty) {
        setState(() => isAddressLoading = false);
        return;
      }

      final defaultAddress = addresses.firstWhere(
            (a) => a.isDefault == true,
        orElse: () => addresses.first,
      );

      _fillAddressFields(defaultAddress);

      setState(() {
        selectedAddress = defaultAddress;
        selectedAddressId = defaultAddress.id;
        isAddressLoading = false;
      });
    } catch (e) {
      setState(() => isAddressLoading = false);
    }
  }

  void _fillAddressFields(AddressModel a) {
    streetController.text = a.street;
    houseController.text = a.house;
    corpusController.text = a.corpus ?? '';
    entranceController.text = a.entrance ?? '';
    floorController.text = a.floor ?? '';
    flatController.text = a.flat ?? '';
    commentController.text = a.comment ?? '';
  }

  // ------------------ CHOOSE ADDRESS ------------------
  Future<void> _chooseAddress() async {
    final token = await _getToken();
    final addresses = await addressService.loadAddresses(token);

    final result = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddressPickerSheet(addresses: addresses),
    );

    if (result == null) return;

    if (result == 'new') return;

    if (result is AddressModel) {
      _fillAddressFields(result);
      setState(() {
        selectedAddress = result;
        selectedAddressId = result.id;
      });
    }
  }

  // ------------------ STREET SEARCH ------------------
  Future<void> searchStreet(String query) async {
    if (query.length < 3) {
      setState(() => streetSuggestions = []);
      return;
    }

    setState(() => isSearchingStreet = true);

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?"
          "format=json&addressdetails=1&limit=5&q=$query Нижний Новгород",
    );

    final response = await http.get(
      url,
      headers: {"User-Agent": "delivery_app/1.0"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        streetSuggestions = List<Map<String, dynamic>>.from(data);
      });
    }

    setState(() => isSearchingStreet = false);
  }

  // ------------------ HOUSE SEARCH (FIAS) ------------------
  Future<void> searchHouse(String query) async {
    if (query.isEmpty) {
      setState(() => houseSuggestions = []);
      return;
    }

    final street = streetController.text.trim();
    final suggestions = await fiasService.suggestHouses(street, query);

    setState(() {
      houseSuggestions = suggestions.take(10).toList();
    });
  }

  // ------------------ ENTRANCE SUGGESTIONS ------------------
  void searchEntrance(String query) {
    if (query.isEmpty) {
      setState(() => entranceSuggestions = []);
      return;
    }

    final allEntrances = List.generate(20, (i) => (i + 1).toString());

    setState(() {
      entranceSuggestions = allEntrances
          .where((e) => e.startsWith(query))
          .take(5)
          .toList();
    });
  }

  // ------------------ INTERVAL PICKER ------------------
  void _openIntervalPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final intervals = [
          '12:00 – 12:30',
          '12:30 – 13:00',
          '13:00 – 13:30',
          '13:30 – 14:00',
          '14:00 – 14:30',
          '14:30 – 15:00',
        ];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.h3('Выберите интервал доставки'),
              const SizedBox(height: AppSpacing.md),
              ...intervals.map((interval) {
                return ListTile(
                  title: Text(interval),
                  onTap: () {
                    setState(() {
                      selectedInterval = interval;
                      intervalError = null;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

// ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.totalFromCart;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Оформление заказа'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildAddressCard(),
          _buildDeliveryCard(),
          _buildCommentCard(),
          _buildPaymentCard(),
          _buildTotalCard(totalPrice),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
      bottom: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: PrimaryButton(
          text: 'Подтвердить заказ',
          loading: _isLoading,
          fullWidth: true,
          onTap: _isLoading ? null : () {
            _submitOrder();
          },

        ),
      ),
    );
  }

// ------------------ ADDRESS CARD ------------------
  Widget _buildAddressCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.h2('Адрес доставки'),
              TextButton(
                onPressed: _chooseAddress,
                child: const Text('Выбрать адрес'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: streetController,
            label: 'Улица',
            icon: Icons.map_outlined,
            onChanged: searchStreet,
          ),

          if (isSearchingStreet)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(minHeight: 2),
            ),

          if (streetSuggestions.isNotEmpty)
            _buildSuggestionBox(
              streetSuggestions.map((s) {
                final address = s['address'] ?? {};
                final road = address['road'] ?? s['display_name'];
                final house = address['house_number'] ?? '';

                return ListTile(
                  title: Text(road),
                  subtitle: house.isNotEmpty ? Text('Дом $house') : null,
                  onTap: () {
                    setState(() {
                      streetController.text = road;
                      houseController.text = house;
                      streetSuggestions = [];
                    });
                  },
                );
              }).toList(),
            ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: houseController,
            label: 'Дом',
            icon: Icons.home_outlined,
            onChanged: searchHouse,
          ),

          if (houseSuggestions.isNotEmpty)
            _buildSuggestionBox(
              houseSuggestions.map((h) {
                return ListTile(
                  title: Text('Дом $h'),
                  onTap: () {
                    setState(() {
                      houseController.text = h;
                      houseSuggestions = [];
                    });
                  },
                );
              }).toList(),
            ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: corpusController,
            label: 'Корпус',
            icon: Icons.apartment_outlined,
          ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: entranceController,
            label: 'Подъезд',
            icon: Icons.door_sliding_outlined,
            onChanged: searchEntrance,
          ),

          if (entranceSuggestions.isNotEmpty)
            _buildSuggestionBox(
              entranceSuggestions.map((e) {
                return ListTile(
                  title: Text('Подъезд $e'),
                  onTap: () {
                    setState(() {
                      entranceController.text = e;
                      entranceSuggestions = [];
                    });
                  },
                );
              }).toList(),
            ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: floorController,
            label: 'Этаж',
            icon: Icons.stairs_outlined,
          ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: flatController,
            label: 'Квартира',
            icon: Icons.home_work_outlined,
          ),

          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            text: 'Выбрать на карте',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );

              if (result != null) {
                setState(() {
                  streetController.text = result['street'] ?? '';
                  houseController.text = result['house'] ?? '';
                  flatController.text = result['flat'] ?? '';
                });
              }
            },
          ),
        ],
      ),
    );
  }

// ------------------ DELIVERY CARD ------------------
  Widget _buildDeliveryCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.h2('Время доставки'),
          const SizedBox(height: AppSpacing.md),

          _buildRadio('Как можно скорее', 'asap'),
          _buildRadio('Через 30 минут', '30min'),
          _buildRadio('Выбрать интервал', 'interval'),

          if (deliveryTime == 'interval') ...[
            const SizedBox(height: AppSpacing.sm),

            GestureDetector(
              onTap: _openIntervalPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.body(
                      selectedInterval ?? 'Выберите интервал доставки',
                    ),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),

            if (intervalError != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: AppText.caption(intervalError!),
              ),
          ],
        ],
      ),
    );
  }

// ------------------ COMMENT CARD ------------------
  Widget _buildCommentCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.h2('Комментарий к заказу'),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: commentController,
            label: 'Например: без лука, позвонить при доставке',
            maxLines: 3,
            icon: Icons.chat_bubble_outline,
          ),
        ],
      ),
    );
  }

// ------------------ PAYMENT CARD ------------------
  Widget _buildPaymentCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.h2('Способ оплаты'),
          const SizedBox(height: AppSpacing.md),

          _buildPayment('Картой онлайн', 'card'),
          _buildPayment('Наличными курьеру', 'cash'),
        ],
      ),
    );
  }

// ------------------ TOTAL CARD ------------------
  Widget _buildTotalCard(double totalPrice) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.h2('Итого'),
          AppText.h2('$totalPrice ₽'),
        ],
      ),
    );
  }

  // ------------------ SUBMIT ORDER ------------------
  Future<void> _submitOrder() async {
    if (deliveryTime == 'interval' && selectedInterval == null) {
      setState(() => intervalError = 'Выберите интервал доставки');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _getToken();

      final newAddress = addressService.fromControllers(
        street: streetController.text.trim(),
        house: houseController.text.trim(),
        corpus: corpusController.text.trim(),
        entrance: entranceController.text.trim(),
        floor: floorController.text.trim(),
        flat: flatController.text.trim(),
        comment: commentController.text.trim(),
      );

      final finalAddress = await controller.ensureAddress(
        token: token,
        oldAddress: selectedAddress,
        newAddress: newAddress,
      );

      selectedAddress = finalAddress;
      selectedAddressId = finalAddress.id;

      final items = widget.items.map((item) {
        return {
          'product_id': item['product']['id'],
          'quantity': item['quantity'],
        };
      }).toList();

      final result = await controller.createOrder(
        token: token,
        addressId: selectedAddressId!,
        comment: commentController.text.trim(),
        paymentMethod: paymentMethod,
        deliveryTime:
        deliveryTime == 'interval' ? selectedInterval! : deliveryTime,
        promoCode: promoController.text.trim(),
        items: items,
        totalPrice: widget.totalFromCart,
      );

      await controller.clearCart(token);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(orderId: result['order_id']),
        ),
            (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка оформления заказа: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// ------------------ RADIO BUTTON ------------------
  Widget _buildRadio(String title, String value) {
    return RadioListTile(
      title: AppText.body(title),
      value: value,
      groupValue: deliveryTime,
      activeColor: Theme
          .of(context)
          .colorScheme
          .primary,
      onChanged: (v) => setState(() => deliveryTime = v!),
    );
  }

// ------------------ PAYMENT RADIO ------------------
  Widget _buildPayment(String title, String value) {
    return RadioListTile<String>(
      title: AppText.body(title),
      value: value,
      groupValue: paymentMethod,
      activeColor: Theme
          .of(context)
          .colorScheme
          .primary,
      onChanged: (v) => setState(() => paymentMethod = v!),
    );
  }

// ------------------ SUGGESTION BOX ------------------
  Widget _buildSuggestionBox(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

}