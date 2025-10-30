import 'package:google_maps_flutter/google_maps_flutter.dart';
class GeoPoint {
  final double lat;
  final double lng;

  GeoPoint({required this.lat, required this.lng});

  LatLng toLatLng() => LatLng(lat, lng);

  factory GeoPoint.fromMap(Map<String, dynamic> map) {
    return GeoPoint(
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
    );
  }
}