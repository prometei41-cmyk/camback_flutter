import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/address_repositiry.dart';
import '../../core/theme/app_card.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/primary_button.dart';
import '../../services/addresses_service.dart';
import '../profile/models/address_model.dart';
import 'edit_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final AddressService addressService = AddressService();
  final AddressRepository repo = AddressRepository();

  List<AddressModel> addresses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access') ?? '';
  }

  Future<void> _loadAddresses() async {
    final token = await _getToken();
    final list = await addressService.loadAddresses(token);

    setState(() {
      addresses = list;
      isLoading = false;
    });
  }

  Future<void> _deleteAddress(int id) async {
    final token = await _getToken();
    final ok = await repo.deleteAddress(token, id);

    setState(() {
      addresses.removeWhere((a) => a.id == id);
    });
  }

  Future<void> _setDefault(int id) async {
    final token = await _getToken();
    final ok = await repo.setDefault(token, id);

    if (ok) {
      await _loadAddresses();
    }
  }

  void _editAddress(AddressModel address) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditAddressScreen(address: address)),
    );

    if (updated == true) {
      _loadAddresses();
    }
  }

  void _addAddress() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditAddressScreen(address: null)),
    );

    if (created == true) {
      _loadAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Мои адреса"), centerTitle: true),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
          ? Center(
              child: AppText.body(
                "У вас пока нет сохранённых адресов",
                color: Colors.black54,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: addresses.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                final a = addresses[i];

                return Dismissible(
                  key: ValueKey(a.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteAddress(a.id),
                  child: _addressCard(a),
                );
              },
            ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: PrimaryButton(text: "Добавить адрес", onTap: _addAddress),
      ),
    );
  }

  Widget _addressCard(AddressModel a) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- ADDRESS TITLE ---
          AppText.h2(
            "${a.street}, ${a.house}"
            "${a.corpus != null ? ', корп. ${a.corpus}' : ''}"
            "${a.flat != null ? ', кв. ${a.flat}' : ''}",
          ),

          if (a.comment != null && a.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            AppText.body(a.comment!, color: Colors.black54),
          ],

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              if (a.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppText.body(
                    "Основной",
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

              const Spacer(),

              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black87),
                onPressed: () => _editAddress(a),
              ),

              IconButton(
                icon: Icon(
                  a.isDefault ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => _setDefault(a.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
