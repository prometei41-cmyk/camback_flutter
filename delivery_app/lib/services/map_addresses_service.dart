import 'package:geocoding/geocoding.dart';

class MapAddressService {
  Future<Map<String, String>> getAddressFromCoords(
      double lat, double lon) async {
    final placemarks = await placemarkFromCoordinates(lat, lon);
    final p = placemarks.first;

    return {
      'street': p.street ?? '',
      'house': p.subThoroughfare ?? '',
      'flat': '',
    };
  }
}
