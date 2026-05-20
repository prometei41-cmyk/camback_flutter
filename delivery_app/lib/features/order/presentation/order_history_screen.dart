import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/order_repository.dart';
import '../../../core/theme/app_card.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_tokens.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderRepository repo = OrderRepository();

  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access') ?? '';
  }

  Future<void> _loadOrders() async {
    final token = await _getToken();

    try {
      final list = await repo.getOrderHistory(token);

      setState(() {
        orders = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка загрузки истории: $e")),
      );
    }
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;

    return "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}";
  }

  Color _statusColor(String status) {
    switch (status) {
      case "new": return Colors.orange;
      case "accepted": return Colors.blue;
      case "cooking": return Colors.deepPurple;
      case "delivering": return Colors.teal;
      case "delivered": return Colors.green;
      case "cancelled": return Colors.red;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case "new": return "Новый";
      case "accepted": return "Принят";
      case "cooking": return "Готовится";
      case "delivering": return "В пути";
      case "delivered": return "Доставлен";
      case "cancelled": return "Отменён";
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("История заказов"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ?  Center(
        child: AppText.body(
          "Вы ещё не делали заказов",
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: orders.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) {
          final o = orders[i];
          return _buildOrderCard(o);
        },
      ),
    );
  }

  Widget _buildOrderCard(dynamic o) {
    final id = o["id"];
    final total = o["total_price"];
    final status = o["status"];
    final created = o["created_at"];
    final address = o["address_text"] ?? "Адрес не указан";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(order: o),
          ),
        );
      },
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ID + DATE ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.h2("Заказ №$id"),
                AppText.body(
                  _formatDate(created),
                  color: Colors.black54,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // --- ADDRESS ---
            AppText.body(address),

            const SizedBox(height: AppSpacing.sm),

            // --- STATUS ---
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _statusColor(status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText.body(
                _statusLabel(status),
                color: _statusColor(status),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // --- TOTAL ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.body("Сумма:"),
                AppText.h3("$total ₽"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
