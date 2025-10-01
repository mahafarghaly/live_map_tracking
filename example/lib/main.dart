import 'package:flutter/material.dart';
import 'package:live_map_tracking/data/models/trip_points.dart';
import 'package:live_map_tracking/live_map_tracking.dart';

void main() {
  runApp(const MyApp());
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
    final tripPoints = rawPoints.map((map) => TripPoint.fromMap(map)).toList();
    return MaterialApp(home: TripMapScreen(tripPoints: tripPoints));
  }
}
