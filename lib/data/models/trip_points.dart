import 'package:google_maps_flutter/google_maps_flutter.dart';
class TripPoint {
  final double lat;
  final double lng;

  TripPoint({required this.lat, required this.lng});

  LatLng toLatLng() => LatLng(lat, lng);

  factory TripPoint.fromMap(Map<String, dynamic> map) {
    return TripPoint(
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
    );
  }
}