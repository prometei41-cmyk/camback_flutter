import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_card.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/primary_button.dart';
import '../../services/addresses_service.dart';
import '../../services/fias_service.dart';
import '../../api/address_repositiry.dart';
import '../../services/map_addresses_service.dart';
import '../order/presentation/map_screen.dart';
import '../profile/models/address_model.dart';


class EditAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const EditAddressScreen({super.key, required this.address});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final AddressService addressService = AddressService();
  final AddressRepository repo = AddressRepository();
  final FiasService fiasService = FiasService();
  final MapAddressService mapService = MapAddressService();

  final streetController = TextEditingController();
  final houseController = TextEditingController();
  final corpusController = TextEditingController();
  final entranceController = TextEditingController();
  final floorController = TextEditingController();
  final flatController = TextEditingController();
  final commentController = TextEditingController();

  List<Map<String, dynamic>> streetSuggestions = [];
  List<String> houseSuggestions = [];
  List<String> entranceSuggestions = [];

  bool isSearchingStreet = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      streetController.text = widget.address!.street;
      houseController.text = widget.address!.house;
      corpusController.text = widget.address!.corpus ?? '';
      entranceController.text = widget.address!.entrance ?? '';
      floorController.text = widget.address!.floor ?? '';
      flatController.text = widget.address!.flat ?? '';
      commentController.text = widget.address!.comment ?? '';
    }
  }

  @override
  void dispose() {
    streetController.dispose();
    houseController.dispose();
    corpusController.dispose();
    entranceController.dispose();
    floorController.dispose();
    flatController.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access') ?? '';
  }

  // ---------------- STREET SEARCH ----------------
  Future<void> searchStreet(String query) async {
    if (query.length < 3) {
      setState(() => streetSuggestions = []);
      return;
    }

    setState(() => isSearchingStreet = true);

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?"
          "format=json&addressdetails=1&limit=5&q=$query Нижний Новгород",
    );

    final response = await http.get(
      url,
      headers: {"User-Agent": "delivery_app/1.0"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        streetSuggestions = List<Map<String, dynamic>>.from(data);
      });
    }

    setState(() => isSearchingStreet = false);
  }

  // ---------------- HOUSE SEARCH (FIAS) ----------------
  Future<void> searchHouse(String query) async {
    if (query.isEmpty) {
      setState(() => houseSuggestions = []);
      return;
    }

    final street = streetController.text.trim();
    final suggestions = await fiasService.suggestHouses(street, query);

    setState(() {
      houseSuggestions = suggestions.take(10).toList();
    });
  }

  // ---------------- ENTRANCE SUGGESTIONS ----------------
  void searchEntrance(String query) {
    if (query.isEmpty) {
      setState(() => entranceSuggestions = []);
      return;
    }

    final all = List.generate(20, (i) => (i + 1).toString());

    setState(() {
      entranceSuggestions = all.where((e) => e.startsWith(query)).take(5).toList();
    });
  }

  // ---------------- SAVE ADDRESS ----------------
  Future<void> _save() async {
    setState(() => isSaving = true);

    try {
      final token = await _getToken();

      final data = addressService.fromControllers(
        street: streetController.text.trim(),
        house: houseController.text.trim(),
        corpus: corpusController.text.trim(),
        entrance: entranceController.text.trim(),
        floor: floorController.text.trim(),
        flat: flatController.text.trim(),
        comment: commentController.text.trim(),
      );

      if (widget.address == null) {
        await addressService.createAddress(token, data);
      } else {
        await repo.updateAddress(token, widget.address!.id, {
          'street': data.street,
          'house': data.house,
          'corpus': data.corpus,
          'entrance': data.entrance,
          'floor': data.floor,
          'flat': data.flat,
          'comment': data.comment,
        });
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка сохранения: $e")),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Редактировать адрес" : "Добавить адрес"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h2("Адрес"),
                const SizedBox(height: AppSpacing.lg),

                _input(
                  controller: streetController,
                  label: "Улица",
                  icon: Icons.map_outlined,
                  onChanged: searchStreet,
                ),

                if (isSearchingStreet)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),

                if (streetSuggestions.isNotEmpty)
                  _suggestionBox(
                    streetSuggestions.map((s) {
                      final address = s["address"] ?? {};
                      final road = address["road"] ?? s["display_name"];
                      final house = address["house_number"] ?? "";

                      return ListTile(
                        title: Text(road),
                        subtitle: house.isNotEmpty ? Text("Дом $house") : null,
                        onTap: () {
                          setState(() {
                            streetController.text = road;
                            houseController.text = house;
                            streetSuggestions = [];
                          });
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: AppSpacing.md),

                _input(
                  controller: houseController,
                  label: "Дом",
                  icon: Icons.home_outlined,
                  onChanged: searchHouse,
                ),

                if (houseSuggestions.isNotEmpty)
                  _suggestionBox(
                    houseSuggestions.map((h) {
                      return ListTile(
                        title: Text("Дом $h"),
                        onTap: () {
                          setState(() {
                            houseController.text = h;
                            houseSuggestions = [];
                          });
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: AppSpacing.md),

                _input(
                  controller: corpusController,
                  label: "Корпус",
                  icon: Icons.apartment_outlined,
                ),

                const SizedBox(height: AppSpacing.md),

                _input(
                  controller: entranceController,
                  label: "Подъезд",
                  icon: Icons.door_sliding_outlined,
                  onChanged: searchEntrance,
                ),

                if (entranceSuggestions.isNotEmpty)
                  _suggestionBox(
                    entranceSuggestions.map((e) {
                      return ListTile(
                        title: Text("Подъезд $e"),
                        onTap: () {
                          setState(() {
                            entranceController.text = e;
                            entranceSuggestions = [];
                          });
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: AppSpacing.md),

                _input(
                  controller: floorController,
                  label: "Этаж",
                  icon: Icons.stairs_outlined,
                ),

                const SizedBox(height: AppSpacing.md),

                _input(
                  controller: flatController,
                  label: "Квартира",
                  icon: Icons.home_work_outlined,
                ),

                const SizedBox(height: AppSpacing.md),

                _input(
                  controller: commentController,
                  label: "Комментарий",
                  icon: Icons.comment_outlined,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            text: "Выбрать на карте",
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );

              if (result != null) {
                setState(() {
                  streetController.text = result['street'] ?? '';
                  houseController.text = result['house'] ?? '';
                  flatController.text = result['flat'] ?? '';
                });
              }
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          PrimaryButton(
            text: isSaving ? "Сохранение..." : (isEdit ? "Сохранить" : "Добавить"),
            loading: isSaving,
            onTap: isSaving ? null : _save,
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(label, color: Colors.black87),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _suggestionBox(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
