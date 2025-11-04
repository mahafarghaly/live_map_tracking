import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/marker_state.dart';

class MarkerStateNotifier extends StateNotifier<MarkerState> {
  MarkerStateNotifier() : super(const MarkerState());

  void setMarkers(Set<Marker> markers) {
    state = state.copyWith(markers: markers);
  }

  void selectMarker(Marker marker) {
    state = state.copyWith(selectedMarker: marker);
  }

  void clearSelection() {
    state = state.copyWith(clearSelected: true);
  }
}

final markerStateProvider =
    StateNotifierProvider<MarkerStateNotifier, MarkerState>(
      (ref) => MarkerStateNotifier(),
    );
