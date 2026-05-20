import 'package:flutter/material.dart';
import '../core/theme/app_text.dart';
import '../core/theme/app_tokens.dart';

class OrderStatusTimeline extends StatelessWidget {
  final List<OrderStatusStep> steps;

  const OrderStatusTimeline({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Circle + Line ---
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: step.isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: step.isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                  ),
              ],
            ),

            const SizedBox(width: AppSpacing.md),

            // --- Text ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.h3(step.title),
                    if (step.subtitle != null)
                      AppText.body(
                        step.subtitle!,
                        color: Colors.black54,
                      ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class OrderStatusStep {
  final String title;
  final String? subtitle;
  final bool isCompleted;

  OrderStatusStep({
    required this.title,
    this.subtitle,
    required this.isCompleted,
  });
}
