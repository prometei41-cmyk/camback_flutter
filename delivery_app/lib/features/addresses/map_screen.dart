import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late YandexMapController _controller;

  Point? selectedPoint;
  String selectedAddress = "Нажмите на карту, чтобы выбрать адрес";

  static const emerald = Color(0xFF2ECC71);

  Future<void> _onMapTap(Point point) async {
    setState(() {
      selectedPoint = point;
      selectedAddress = "Определение адреса...";
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final street = p.street ?? "";
        final house = p.subThoroughfare ?? "";

        setState(() {
          selectedAddress = "$street, $house";
        });
      }
    } catch (e) {
      setState(() {
        selectedAddress = "Не удалось определить адрес";
      });
    }
  }

  void _confirm() {
    if (selectedPoint == null) return;

    Navigator.pop(context, {
      "street": selectedAddress.split(",").first.trim(),
      "house": selectedAddress.contains(",")
          ? selectedAddress.split(",")[1].trim()
          : "",
      "flat": "",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Выбор на карте"),
        backgroundColor: emerald,
      ),
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (c) => _controller = c,
            onMapTap: _onMapTap,
          ),

          // --- ADDRESS PANEL ---
          Positioned(
            left: 16,
            right: 16,
            bottom: 100,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                selectedAddress,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          // --- CONFIRM BUTTON ---
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: emerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: selectedPoint == null ? null : _confirm,
                child: const Text(
                  "Подтвердить адрес",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
