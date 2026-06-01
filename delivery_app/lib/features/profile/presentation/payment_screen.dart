import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для TextInputFormatter

import '../../../core/theme/app_card.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_tokens.dart'; // Предполагается, что здесь есть AppSpacing и AppRadius
import '../../../core/theme/primary_button.dart';
import '../../../../services/payment_service.dart'; // Импортируем PaymentService

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPayment = 'card'; // По умолчанию карта

  // Контроллеры для полей ввода
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Ключ для формы, чтобы можно было валидировать поля
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Флаг для отображения индикатора загрузки

  @override
  void dispose() {
    // Освобождаем ресурсы контроллеров
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // Функция для очистки полей формы (опционально)
  void _clearForm() {
    _cardNumberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
  }

  // Функция для обработки нажатия кнопки "Добавить карту"
  Future<void> _addCard() async {
    if (_formKey.currentState!.validate()) {
      // Если форма валидна, показываем индикатор загрузки и пробуем обработать платеж
      setState(() { _isLoading = true; });

      try {
        final success = await PaymentService.processPayment(
          cardNumber: _cardNumberController.text.replaceAll(' ', ''), // Удаляем пробелы
          expiryDate: _expiryDateController.text,
          cvv: _cvvController.text,
          // Для добавления карты сумма может быть 0 или минимальная тестовая сумма,
          // если требуется какая-то проверка. Если просто добавляем, то 0.0.
          amount: 0.0,
        );

        if (success) {
          // Успех: показать сообщение и, возможно, вернуться или обновить UI
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Карта успешно добавлена!')),
          );
          _clearForm(); // Очищаем поля после успешного добавления
          // Здесь можно добавить логику:
          // - Вернуться назад: Navigator.of(context).pop();
          // - Обновить список карт (если есть где-то список)
        } else {
          // Платеж не удался (если processPayment возвращает false, а не выбрасывает исключение)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось добавить карту. Попробуйте позже.')),
          );
        }
      } catch (e) {
        // Ошибка при обработке платежа (например, исключение из PaymentService)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      } finally {
        // Убираем индикатор загрузки, независимо от результата
        if (mounted) { // Проверка, что виджет все еще активен
          setState(() { _isLoading = false; });
        }
      }
    }
  }

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
                // Используем AppText.medium и AppText.caption, если они существуют в вашем AppText
                // Если нет, можно использовать Text напрямую или добавить их в AppText
                title: AppText.medium('Картой онлайн', fontSize: 16), // Пример использования
                subtitle: AppText.caption('Оплата через банковскую карту', fontSize: 12, color: Colors.grey[600]), // Пример использования
                value: 'card',
                groupValue: selectedPayment,
                onChanged: (value) {
                  setState(() => selectedPayment = value!);
                  // При выборе карты, очищаем поля, если они были заполнены
                  if (value == 'card') {
                    _clearForm(); // Очищаем поля при переключении на карту
                  }
                },
              ),
            ),
            // TODO: Добавить другие способы оплаты, если нужно
            // Например, наличными курьеру
            AppCard(
              child: RadioListTile<String>(
                title: AppText.medium('Наличными курьеру', fontSize: 16),
                subtitle: AppText.caption('Оплата при получении заказа', fontSize: 12, color: Colors.grey[600]),
                value: 'cash',
                groupValue: selectedPayment,
                onChanged: (value) {
                  setState(() => selectedPayment = value!);
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Отображаем форму ввода карты только если выбрана "Картой онлайн"
            if (selectedPayment == 'card')
              Expanded( // Используем Expanded, чтобы форма заняла оставшееся место и была прокручиваемой, если нужно
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView( // Добавлено для прокрутки, если форма большая
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Поле для номера карты
                        TextFormField(
                          controller: _cardNumberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            // Форматирование номера карты (например, каждые 4 цифры пробел)
                            LengthLimitingTextInputFormatter(19), // Макс. 19 цифр (Visa/MC 16, Amex 15) + пробелы
                            _CardNumberFormatter(), // Кастомный форматтер
                          ],
                          decoration: InputDecoration(
                            labelText: 'Номер карты',
                            hintText: 'xxxx xxxx xxxx xxxx',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg)), // <-- ИСПОЛЬЗУЕТСЯ AppRadius.lg
                            suffixIcon: const Icon(Icons.credit_card),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите номер карты';
                            }
                            // Базовая проверка на длину (16-19 цифр) после удаления пробелов
                            if (value.replaceAll(' ', '').length < 16 || value.replaceAll(' ', '').length > 19) {
                              return 'Некорректный номер карты';
                            }
                            return null; // Валидация пройдена
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Поле для срока действия и CVV в одну строку
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _expiryDateController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(5), // MMYY (5 символов)
                                  _ExpiryDateFormatter(), // Кастомный форматтер
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Срок действия',
                                  hintText: 'MM/YY',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg)), // <-- ИСПОЛЬЗУЕТСЯ AppRadius.lg
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Введите срок';
                                  }
                                  // Простая проверка формата MM/YY
                                  final parts = value.split('/');
                                  if (parts.length != 2) return 'Неверный формат';
                                  final month = int.tryParse(parts[0]);
                                  final year = int.tryParse(parts[1]);
                                  if (month == null || year == null || month < 1 || month > 12 || year < 0) { // Можно добавить проверку на актуальность года
                                    return 'Неверный месяц/год';
                                  }
                                  // TODO: Добавить проверку на актуальность срока действия (не прошедшую дату)
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: TextFormField(
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4), // CVV может быть 3 или 4 цифры
                                ],
                                decoration: InputDecoration(
                                  labelText: 'CVV',
                                  hintText: 'xxx',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg)), // <-- ИСПОЛЬЗУЕТСЯ AppRadius.lg
                                  suffixIcon: const Icon(Icons.lock),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Введите CVV';
                                  }
                                  if (value.length < 3 || value.length > 4) {
                                    return 'Некорректный CVV';
                                  }
                                  return null;
                                },
                                obscureText: true, // Скрываем ввод CVV
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Кнопка "Добавить карту"
                        // Кнопка теперь внутри Form, чтобы ее нажатие вызывало валидацию
                        if (_isLoading) // Показываем индикатор загрузки, если идет обработка
                          const Center(child: CircularProgressIndicator())
                        else
                          PrimaryButton.fullWidth(
                            text: 'Добавить карту',
                            onTap: _addCard, // Вызываем нашу новую функцию
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            // Spacer() убрал, так как используем Expanded для формы
            // const Spacer(),
            // Кнопка добавить карту (перенесена внутрь Form)
            // PrimaryButton.fullWidth(
            //   text: 'Добавить новую карту',
            //   onTap: () { // Здесь будет вызов _addCard
            //     _addCard();
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

// --- Вспомогательные форматтеры для полей ввода ---

// Форматтер для номера карты (добавляет пробелы каждые 4 цифры)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text.replaceAll(' ', ''); // Убираем существующие пробелы
    String formattedText = '';
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formattedText += ' '; // Добавляем пробел каждые 4 цифры
      }
      formattedText += text[i];
    }

    // Если количество символов изменилось, обновляем значение
    if (formattedText != newValue.text) {
      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
    return newValue;
  }
}

// Форматтер для срока действия (MM/YY)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text;
    String formattedText = '';

    // Добавляем '/' после второго символа, если он еще не там
    if (text.length > 2) {
      formattedText = '${text.substring(0, 2)}/${text.substring(2)}';
    } else {
      formattedText = text;
    }

    // Ограничиваем длину введенного текста
    if (formattedText.length > 5) {
      formattedText = formattedText.substring(0, 5);
    }

    // Если отформатированный текст отличается от нового значения, обновляем
    if (formattedText != newValue.text) {
      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
    return newValue;
  }
}

// --- Убедитесь, что у вас есть эти методы в AppText, если они используются ---
// Если их нет, добавьте или используйте Text напрямую.
// Пример:
// abstract class AppText {
//   static Text h2(String text, {double fontSize = 24, Color? color, TextAlign? textAlign, FontWeight? fontWeight, double? lineHeight}) => Text(text, style: TextStyle(...));
//   static Text medium(String text, {double fontSize = 14, Color? color, TextAlign? textAlign, FontWeight? fontWeight, double? lineHeight}) => Text(text, style: TextStyle(...));
//   static Text caption(String text, {double fontSize = 12, Color? color, TextAlign? textAlign, FontWeight? fontWeight, double? lineHeight}) => Text(text, style: TextStyle(...));
// }
