import 'package:flutter/material.dart';
import '../../../core/theme/app_card.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/primary_button.dart';


class OrderSuccessScreen extends StatelessWidget {
  final int orderId;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 96,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppText.h1('Заказ оформлен!'),

                  const SizedBox(height: AppSpacing.sm),

                  AppText.body(
                    'Номер заказа:',
                    color: Colors.black54,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AppText.h2('#$orderId'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              text: 'На главную',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/main',
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

