import 'package:flutter/material.dart';
import '../../../api/auth_repository.dart';
import '../../../core/theme/app_card.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/primary_button.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await AuthRepository().getProfile();
      setState(() {
        profile = data;
        isLoading = false;
      });
    } catch (e) {
      await AuthRepository().logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final email = profile?['email'] ?? 'Неизвестно';
    final name = profile?['name'] ?? 'Пользователь';
    final phone = profile?['phone'] ?? 'Не указан';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Личный кабинет"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // --- AVATAR + NAME ---
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: AppText.h1(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppText.h2(name),
                const SizedBox(height: AppSpacing.xs),
                AppText.body(email, color: Colors.black54),
                AppText.body(phone, color: Colors.black54),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // --- PERSONAL INFO ---
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h2("Профиль"),
                const SizedBox(height: AppSpacing.md),

                _menuItem(
                  icon: Icons.person,
                  title: "Редактировать профиль",
                  onTap: () async {
                    final updated = await Navigator.pushNamed(
                      context,
                      '/edit-profile',
                      arguments: profile,
                    );
                    if (updated is Map<String, dynamic>) {
                      setState(() {
                        profile = {...profile!, ...updated};
                      });
                    }
                  },
                ),

                _menuItem(
                  icon: Icons.shopping_bag,
                  title: "История заказов",
                  onTap: () => Navigator.pushNamed(context, '/order_history'),
                ),

                _menuItem(
                  icon: Icons.location_on,
                  title: "Адреса доставки",
                  onTap: () => Navigator.pushNamed(context, '/addresses'),
                ),

                _menuItem(
                  icon: Icons.credit_card,
                  title: "Способы оплаты",
                  onTap: () => Navigator.pushNamed(context, '/payments'),
                ),

                _menuItem(
                  icon: Icons.notifications,
                  title: "Уведомления",
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                ),

                _menuItem(
                  icon: Icons.support_agent,
                  title: "Поддержка",
                  onTap: () => Navigator.pushNamed(context, '/support'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // --- LOGOUT BUTTON ---
          PrimaryButton(
            text: "Выйти из аккаунта",
            onTap: _logout,
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: AppText.body(title)),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
