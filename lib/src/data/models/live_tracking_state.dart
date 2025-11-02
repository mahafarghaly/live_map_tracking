import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';

class LiveTrackingState {
  final GeoPoint? currentPosition;
  final List<GeoPoint> traveledPath;
  final Marker? startMarker;
  final Marker? endMarker;
  final Marker? movingMarker;

  LiveTrackingState({
    this.currentPosition,
    this.traveledPath = const [],
    this.startMarker,
    this.endMarker,
    this.movingMarker,
  });

  LiveTrackingState copyWith({
    GeoPoint? currentPosition,
    List<GeoPoint>? traveledPath,
    Marker? startMarker,
    Marker? endMarker,
    Marker? movingMarker,
  }) {
    return LiveTrackingState(
      currentPosition: currentPosition ?? this.currentPosition,
      traveledPath: traveledPath ?? this.traveledPath,
      startMarker: startMarker ?? this.startMarker,
      endMarker: endMarker ?? this.endMarker,
      movingMarker: movingMarker ?? this.movingMarker,
    );
  }
}
