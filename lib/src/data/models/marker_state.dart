import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerState {
  final Set<Marker> markers;
  final Marker? selectedMarker;
  final LatLng? selectedPosition;

  const MarkerState({
    this.markers = const {},
    this.selectedMarker,
    this.selectedPosition,
  });

  MarkerState copyWith({
    Set<Marker>? markers,
    Marker? selectedMarker,
    LatLng? selectedPosition,
    bool clearSelected = false,
  }) {
    return MarkerState(
      markers: markers ?? this.markers,
      selectedMarker: clearSelected
          ? null
          : (selectedMarker ?? this.selectedMarker),
      selectedPosition: clearSelected
          ? null
          : (selectedPosition ?? this.selectedPosition),
    );
  }
}
