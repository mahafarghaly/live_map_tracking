import 'package:flutter/material.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rawPoints = [
      {"lat": 30.55549, "lng": 31.70253},
      {"lat": 30.55441, "lng": 31.7031},
      {"lat": 30.55441, "lng": 31.7031},
    ];
    final tripPoints = rawPoints.map((map) => GeoPoint.fromMap(map)).toList();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("App Name"),),
        body: StaticRoute(
          directionList: tripPoints,
          statIcon: "packages/live_map_tracking/assets/images/marker_green.png",
          endIcon: "packages/live_map_tracking/assets/images/marker.png",
        ),
      ),
    );
  }
}
