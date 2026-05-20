import 'package:flutter/material.dart';
import '../../../core/theme/app_card.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/primary_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPayment = 'card'; // По умолчанию карта

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Способы оплаты'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h2('Выберите способ оплаты'),
            const SizedBox(height: AppSpacing.md),

            // Карта онлайн
            AppCard(
              child: RadioListTile<String>(
                title: AppText.body('Картой онлайн'),
                subtitle: AppText.caption('Оплата через банковскую карту'),
                value: 'card',
                groupValue: selectedPayment,
                onChanged: (value) => setState(() => selectedPayment = value!),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Наличными
            AppCard(
              child: RadioListTile<String>(
                title: AppText.body('Наличными курьеру'),
                subtitle: AppText.caption('Оплата при получении заказа'),
                value: 'cash',
                groupValue: selectedPayment,
                onChanged: (value) => setState(() => selectedPayment = value!),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Сохраненные карты (заглушка)
            AppText.h3('Сохраненные карты'),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: ListTile(
                leading: const Icon(Icons.credit_card),
                title: AppText.body('**** **** **** 1234'),
                subtitle: AppText.caption('Visa • Истекает 12/26'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Удалить карту
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Карта удалена')),
                    );
                  },
                ),
              ),
            ),

            const Spacer(),

            // Кнопка добавить карту
            PrimaryButton.fullWidth(
              text: 'Добавить новую карту',
              onTap: () {
                // Переход к добавлению карты
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Добавление карты (в разработке)'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
