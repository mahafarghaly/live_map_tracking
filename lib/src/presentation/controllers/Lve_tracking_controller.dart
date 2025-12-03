import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
import 'package:live_map_tracking/src/core/network/api_constants.dart';
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
    required String movingIcon,
    required String apikey,
    String? endIcon,
    GeoPoint? endPoint,

  }) async {
    validateLiveTrackingInputs(endIcon: endIcon, endPoint: endPoint);
    LatLng? firstPosition;

    stream.listen((position) async {
      if (firstPosition == null) {
        firstPosition =  position.toLatLng();
        final startMarker = await LiveMapTracking.displayMarker(
          markerId: 'start',
          position: GeoPoint(lat: firstPosition!.latitude, lng: firstPosition!.longitude),
          assetIcon: startIcon,
        );

        Marker? endMarker;
        if (endIcon != null && endPoint != null) {
          endMarker = await LiveMapTracking.displayMarker(
            markerId: 'end',
            position: GeoPoint(lat: endPoint.lat, lng: endPoint.lng),
            assetIcon: endIcon,
          );
          await drawRoutePolyline(
            apikey,
            LatLng(position.lat, position.lng),
            LatLng(endPoint.lat, endPoint.lng),
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

  Future<void> drawRoutePolyline(String apikey,LatLng start, LatLng end) async {
    PolylinePoints polylinePoints = PolylinePoints(apiKey: apikey);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(start.latitude, start.longitude),
        destination: PointLatLng(end.latitude, end.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      final route = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      state = state.copyWith(actualPolyline: route);
    } else {
      print('Polyline error: ${result.errorMessage}');
    }
  }
}
