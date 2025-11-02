import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
import 'package:live_map_tracking/src/data/models/live_tracking_state.dart';
import '../../core/errors/assertions.dart';

final liveTrackingProvider =
    StateNotifierProvider<LiveTrackingNotifier, LiveTrackingState>(
      (ref) => LiveTrackingNotifier(),
    );

class LiveTrackingNotifier extends StateNotifier<LiveTrackingState> {
  LiveTrackingNotifier() : super(LiveTrackingState());

  GoogleMapController? mapController;

  Future<void> initialize({
    required Stream<GeoPoint> stream,
    required String startIcon,
    String? endIcon,
    GeoPoint? endPoint,
    required String movingIcon,
  }) async {
    validateLiveTrackingInputs(endIcon: endIcon, endPoint: endPoint);
    LatLng? firstPosition;

    stream.listen((position) async {
      if (firstPosition == null) {
        firstPosition = position.toLatLng();
        final startMarker = await LiveMapTracking.displayMarker(
          markerId: 'start',
          position: GeoPoint(lat: position.lat, lng: position.lng),
          assetIcon: startIcon,
        );

        Marker? endMarker;
        if (endIcon != null && endPoint != null) {
          endMarker = await LiveMapTracking.displayMarker(
            markerId: 'end',
            position: GeoPoint(lat: endPoint.lat, lng: endPoint.lng),
            assetIcon: endIcon,
          );
        }
        state = state.copyWith(startMarker: startMarker, endMarker: endMarker);
      }
      final movingMarker = await LiveMapTracking.displayMarker(
        markerId: 'moving',
        position: GeoPoint(lat: position.lat, lng: position.lng),
        assetIcon: movingIcon,
      );
      final newPath = [...state.traveledPath, position];

      state = state.copyWith(
        currentPosition: position,
        movingMarker: movingMarker,
        traveledPath: newPath,
      );
    });
  }
}
