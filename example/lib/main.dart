import 'package:flutter/material.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LatLng> tripPoints = const [
      LatLng(30.0444, 31.2357),
      LatLng(30.0500, 31.2400),
      LatLng(30.0600, 31.2450),
    ];
    return MaterialApp(
      home: TripMapScreen(tripPoints: tripPoints,),

    );
  }
}
