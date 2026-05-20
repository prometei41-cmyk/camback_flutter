import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ---------------------- ЗОНЫ ДОСТАВКИ ----------------------
  final List<List<Point>> deliveryZones = [
    [
      const Point(latitude: 56.2965, longitude: 43.9361),
      const Point(latitude: 56.2980, longitude: 43.9400),
      const Point(latitude: 56.2950, longitude: 43.9450),
      const Point(latitude: 56.2930, longitude: 43.9380),
    ],
  ];

  bool _isInsideZone = true;

  // ---------------------- ТЕКУЩАЯ ТОЧКА ----------------------
  Point _targetPoint = const Point(latitude: 56.2965, longitude: 43.9361);

  // ---------------------- КУРЬЕР ----------------------
  final Point _courierPoint = const Point(latitude: 56.3000, longitude: 43.9300);

  // ---------------------- КОНТРОЛЛЕРЫ ----------------------
  final streetController = TextEditingController();
  final houseController = TextEditingController();
  final flatController = TextEditingController();

  late YandexMapController _mapController;

  // ---------------------- ОБЪЕКТЫ КАРТЫ ----------------------
  final List<MapObject> _mapObjects = [];

  // ---------------------- DEBOUNCE ----------------------
  Timer? _debounce;

  // ---------------------- ПОДСКАЗКИ ----------------------
  List<SuggestItem> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _initMapObjects();
    _updateAddressFromYandex(_targetPoint);
  }

  @override
  void dispose() {
    streetController.dispose();
    houseController.dispose();
    flatController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ---------------------- ИНИЦИАЛИЗАЦИЯ ----------------------
  void _initMapObjects() {
    // Полигоны зон доставки
    for (int i = 0; i < deliveryZones.length; i++) {
      _mapObjects.add(
        PolygonMapObject(
          mapId: MapObjectId('zone_$i'),
          polygon: Polygon(
            outerRing: LinearRing(points: deliveryZones[i]),
            innerRings: [],
          ),
          fillColor: Colors.green.withOpacity(0.15),
          strokeColor: Colors.green,
          strokeWidth: 3,
        ),
      );
    }

    // Маркер выбранной точки
    _mapObjects.add(
      PlacemarkMapObject(
        mapId: const MapObjectId('selected_point'),
        point: _targetPoint,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/pin.png'),
            scale: 1.5,
          ),
        ),
      ),
    );
  }

  // ---------------------- ОБНОВЛЕНИЕ МАРКЕРА ----------------------
  void _updateSelectedPlacemark(Point point) {
    final index = _mapObjects.indexWhere(
          (m) => m.mapId.value == 'selected_point',
    );

    if (index == -1) return;

    final old = _mapObjects[index] as PlacemarkMapObject;
    _mapObjects[index] = old.copyWith(point: point);

    setState(() {});
  }

  // ---------------------- ПРОВЕРКА ЗОНЫ ----------------------
  bool _isPointInPolygon(Point point, List<Point> polygon) {
    int intersections = 0;

    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];

      final bool condY =
          (point.latitude > p1.latitude) != (point.latitude > p2.latitude);
      if (!condY) continue;

      final double xIntersection =
          (p2.longitude - p1.longitude) *
              (point.latitude - p1.latitude) /
              (p2.latitude - p1.latitude) +
              p1.longitude;

      if (point.longitude < xIntersection) intersections++;
    }

    return intersections % 2 == 1;
  }

  bool _isPointInAnyZone(Point point) {
    for (final zone in deliveryZones) {
      if (_isPointInPolygon(point, zone)) return true;
    }
    return false;
  }

  // ---------------------- ГЕОКОДИНГ ----------------------
  Future<void> _updateAddressFromYandex(Point point) async {
    final session = YandexSearch.searchByPoint(
      point: point,
      zoom: 16,
      searchOptions: const SearchOptions(),
    );

    final result = await session.result;

    if (result.items == null || result.items!.isEmpty) return;

    final meta = result.items!.first.toponymMetadata;
    final address = meta?.address;

    final street = address?.addressComponents[SearchComponentKind.street];
    final house = address?.addressComponents[SearchComponentKind.house];

    setState(() {
      streetController.text = street ?? '';
      houseController.text = house ?? '';
    });
  }

  // ---------------------- ПОИСК ПО ТЕКСТУ ----------------------
  Future<void> _searchAddressByText(String query) async {
    if (query.isEmpty) return;

    final session = YandexSearch.searchByText(
      searchText: query,
      geometry: Geometry.fromBoundingBox(
        const BoundingBox(
          southWest: Point(latitude: 56.20, longitude: 43.80),
          northEast: Point(latitude: 56.40, longitude: 44.10),
        ),
      ),
      searchOptions: const SearchOptions(),
    );

    final result = await session.result;

    if (result.items == null || result.items!.isEmpty) return;

    final point = result.items!.first.geometry.first.point;
    if (point == null) return;

    _moveToPoint(point);
  }

  // ---------------------- ПОДСКАЗКИ ----------------------
  Future<void> _loadSuggestions(String text) async {
    if (text.isEmpty) {
      setState(() => _showSuggestions = false);
      return;
    }

    final session = YandexSuggest.getSuggestions(
      text: text,
      boundingBox: const BoundingBox(
        southWest: Point(latitude: 56.20, longitude: 43.80),
        northEast: Point(latitude: 56.40, longitude: 44.10),
      ),
      suggestOptions: const SuggestOptions(
        suggestType: SuggestType.geo,
      ),
    );

    final result = await session.result;

    setState(() {
      _suggestions = result.items ?? [];
      _showSuggestions = _suggestions.isNotEmpty;
    });
  }

  void _selectSuggestion(SuggestItem item) {
    final point = item.center;
    if (point == null) return;

    streetController.text = item.title;
    _showSuggestions = false;

    _moveToPoint(point);
  }

  // ---------------------- ПЕРЕМЕЩЕНИЕ КАМЕРЫ ----------------------
  void _moveToPoint(Point point) {
    _targetPoint = point;
    _updateSelectedPlacemark(point);

    _mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 16),
      ),
    );

    final inside = _isPointInAnyZone(point);
    setState(() => _isInsideZone = inside);

    _updateAddressFromYandex(point);
  }

  // ---------------------- МАРШРУТ КУРЬЕРА ----------------------
  Future<void> _buildRoute() async {
    final session = YandexDriving.requestRoutes(
      points: [
        RequestPoint(
          point: _courierPoint,
          requestPointType: RequestPointType.wayPoint,
        ),
        RequestPoint(
          point: _targetPoint,
          requestPointType: RequestPointType.wayPoint,
        ),
      ],
      drivingOptions: const DrivingOptions(),
    );

    final result = await session.result;

    if (result.routes == null || result.routes!.isEmpty) return;

    final route = result.routes!.first;

    _mapObjects.removeWhere((m) => m.mapId.value == 'route');

    _mapObjects.add(
      PolylineMapObject(
        mapId: const MapObjectId('route'),
        polyline: Polyline(points: route.geometry),
        strokeColor: Colors.blue,
        strokeWidth: 4,
      ),
    );

    setState(() {});
  }

  // ---------------------- UI ПОДСКАЗОК ----------------------
  Widget _buildSuggestions() {
    if (!_showSuggestions || _suggestions.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: _suggestions.map((s) {
          return ListTile(
            title: Text(s.title),
            subtitle: s.subtitle != null ? Text(s.subtitle!) : null,
            onTap: () => _selectSuggestion(s),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------- UI АДРЕСА ----------------------
  Widget _buildAddressCard() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: streetController,
                onChanged: _loadSuggestions,
                decoration: const InputDecoration(
                  labelText: "Улица",
                  prefixIcon: Icon(Icons.map_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: houseController,
                decoration: const InputDecoration(
                  labelText: "Дом",
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: flatController,
                decoration: const InputDecoration(
                  labelText: "Квартира (необязательно)",
                  prefixIcon: Icon(Icons.apartment_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    _isInsideZone ? Icons.check_circle : Icons.error,
                    color: _isInsideZone ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isInsideZone
                        ? "В зоне доставки"
                        : "Адрес вне зоны доставки",
                    style: TextStyle(
                      color: _isInsideZone ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _buildRoute,
                icon: const Icon(Icons.directions),
                label: const Text("Маршрут курьера"),
              ),
            ],
          ),
        ),
        _buildSuggestions(),
      ],
    );
  }

  // ---------------------- BUILD ----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Адрес доставки")),
      body: Column(
        children: [
          _buildAddressCard(),
          Expanded(
            child: Stack(
              children: [
                YandexMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _mapController.moveCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: _targetPoint, zoom: 15),
                      ),
                    );
                  },
                  onCameraPositionChanged: (pos, reason, finished) {
                    if (!finished) return;

                    _debounce?.cancel();
                    _debounce = Timer(
                      const Duration(milliseconds: 300),
                          () {
                        _targetPoint = pos.target;
                        _updateSelectedPlacemark(_targetPoint);

                        final inside = _isPointInAnyZone(_targetPoint);
                        setState(() => _isInsideZone = inside);

                        _updateAddressFromYandex(_targetPoint);
                      },
                    );
                  },
                  mapObjects: _mapObjects,
                ),
                IgnorePointer(
                  child: Center(
                    child: Icon(Icons.location_pin,
                        size: 48, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isInsideZone
                  ? () {
                Navigator.pop(context, {
                  'point': _targetPoint,
                  'street': streetController.text,
                  'house': houseController.text,
                  'flat': flatController.text,
                });
              }
                  : null,
              child: const Text("Выбрать адрес"),
            ),
          ),
        ],
      ),
    );
  }
}
