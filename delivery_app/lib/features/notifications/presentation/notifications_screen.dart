import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/app_scaffold.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_tokens.dart';
import '../api/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repository = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _repository.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Обработка ошибки, например, показать Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки уведомлений: $e')),
      );
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      await _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      await _repository.deleteNotification(id);
      await _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        title: AppText.h2("Уведомления"),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () async {
                for (final n in _notifications) {
                  await _repository.deleteNotification(n.id);
                }
                await _loadNotifications();
              },
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            AppText.body("У вас нет уведомлений"),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Dismissible(
            key: Key(notification.id.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _deleteNotification(notification.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: Icon(
                notification.isRead ? Icons.notifications : Icons.notifications_active,
                color: notification.isRead ? Colors.grey : Theme.of(context).colorScheme.primary,
              ),
              title: AppText.h3(notification.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.body(notification.body),
                  const SizedBox(height: AppSpacing.xs),
                  AppText.caption(
                    DateFormat('dd.MM.yyyy HH:mm').format(notification.timestamp),
                    color: Colors.grey,
                  ),
                ],
              ),
              trailing: notification.isRead
                  ? null
                  : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => _markAsRead(notification.id),
              ),
              onTap: () {
                if (!notification.isRead) {
                  _markAsRead(notification.id);
                }
                // Здесь можно добавить навигацию по data, например, к заказу
                // if (notification.data.containsKey('order_id')) {
                //   Navigator.pushNamed(context, '/order_details', arguments: notification.data['order_id']);
                // }
              },
            ),
          );
        },
      ),
    );
  }
}
