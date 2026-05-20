import 'package:flutter/material.dart';
import '../profile/models/address_model.dart';

class AddressPickerSheet extends StatelessWidget {
  final List<AddressModel> addresses;

  const AddressPickerSheet({super.key, required this.addresses});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выберите адрес',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...addresses.map((a) {
              return ListTile(
                title: Text('${a.street}, ${a.house}'),
                subtitle: Text(
                  [
                    if (a.corpus != null && a.corpus!.isNotEmpty)
                      'корп. ${a.corpus}',
                    if (a.entrance != null && a.entrance!.isNotEmpty)
                      'подъезд ${a.entrance}',
                    if (a.flat != null && a.flat!.isNotEmpty)
                      'кв. ${a.flat}',
                  ].join(', '),
                ),
                trailing: a.isDefault == true
                    ? const Icon(Icons.star, color: Colors.amber)
                    : null,
                onTap: () => Navigator.pop(context, a),
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'new'),
              child: const Text('Добавить новый адрес'),
            ),
          ],
        ),
      ),
    );
  }
}
