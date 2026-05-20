import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/cart_repository.dart';
import '../../../api/order_repository.dart';
import '../../../core/theme/app_card.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/primary_button.dart';
import '../../../services/addresses_service.dart';
import '../../../ui/order_status_timeline.dart';
import '../logic/order_controller.dart';
import 'order_screen.dart';


class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case "new":
        return Colors.orange;
      case "accepted":
        return Colors.blue;
      case "cooking":
        return Colors.deepPurple;
      case "delivering":
        return Colors.teal;
      case "delivered":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case "new":
        return "Новый";
      case "accepted":
        return "Принят";
      case "cooking":
        return "Готовится";
      case "delivering":
        return "В пути";
      case "delivered":
        return "Доставлен";
      case "cancelled":
        return "Отменён";
      default:
        return status;
    }
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;

    return "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final id = order["id"];
    final created = order["created_at"];
    final status = order["status"];
    final address = order["address_text"] ?? "Адрес не указан";
    final payment = order["payment_method"] ?? "Не указано";
    final comment = order["comment"] ?? "";
    final deliveryTime = order["delivery_time"] ?? "asap";
    final total = order["total_price"] ?? 0;
    final items = order["items"] ?? [];

    // --- Timeline steps based on status ---
    final steps = [
      OrderStatusStep(
        title: "Новый",
        subtitle: "Заказ создан",
        isCompleted: status != "new",
      ),
      OrderStatusStep(
        title: "Принят",
        subtitle: "Принят в работу",
        isCompleted: ["accepted", "cooking", "delivering", "delivered"].contains(status),
      ),
      OrderStatusStep(
        title: "Готовится",
        subtitle: "Кухня готовит заказ",
        isCompleted: ["cooking", "delivering", "delivered"].contains(status),
      ),
      OrderStatusStep(
        title: "В пути",
        subtitle: "Курьер везёт заказ",
        isCompleted: ["delivering", "delivered"].contains(status),
      ),
      OrderStatusStep(
        title: "Доставлен",
        subtitle: "Заказ завершён",
        isCompleted: status == "delivered",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Заказ №$id"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // --- TIMELINE ---
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h2("Статус заказа"),
                const SizedBox(height: AppSpacing.md),
                OrderStatusTimeline(steps: steps),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- ORDER INFO ---
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h2("Информация"),
                const SizedBox(height: AppSpacing.md),

                _row("Дата:", _formatDate(created)),
                const SizedBox(height: AppSpacing.sm),

                _statusBadge(status),
                const SizedBox(height: AppSpacing.sm),

                _row("Адрес:", address),
                const SizedBox(height: AppSpacing.sm),

                _row("Оплата:", payment == "card" ? "Картой" : "Наличными"),

                if (comment.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _row("Комментарий:", comment),
                ],

                const SizedBox(height: AppSpacing.sm),

                _row(
                  "Доставка:",
                  deliveryTime == "asap"
                      ? "Как можно скорее"
                      : deliveryTime == "30min"
                      ? "Через 30 минут"
                      : deliveryTime,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- ITEMS ---
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h2("Состав заказа"),
                const SizedBox(height: AppSpacing.md),

                ...items.map((item) {
                  final product = item["product"];
                  final name = product["name"];
                  final price = product["price"];
                  final qty = item["quantity"];

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: AppText.body(name)),
                        AppText.body("×$qty"),
                        const SizedBox(width: 12),
                        AppText.body(
                          "${price * qty} ₽",
                          color: Colors.black,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- TOTAL ---
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.h2("Итого"),
                AppText.h2("$total ₽"),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // --- REORDER BUTTON ---
          PrimaryButton(
            text: "Повторить заказ",
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('access') ?? '';

              final controller = OrderController(
                addressService: AddressService(),
                orderRepository: OrderRepository(),
                cartRepository: CartRepository(),
              );

              await controller.reorder(token, order["items"]);

              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderScreen(
                    items: order["items"],
                    totalFromCart: order["total_price"].toDouble(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(label, color: Colors.black87),
        const SizedBox(width: 4),
        Expanded(child: AppText.body(value)),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText.body(
        _statusLabel(status),
        color: color,
      ),
    );
  }
}
