import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';

import '../../controllers/Lve_tracking_controller.dart';

class LiveTracking extends ConsumerWidget {
  final Stream<GeoPoint> stream;
  final String startIcon;
  final String? endIcon;
  final GeoPoint? endPoint;
  final String movingIcon;
  final Color? polylineColor;
  final Color? polylineLiveColor;
  final int? polyLineWidth;
  final int? polyLineLiveWidth;

  const LiveTracking({
    required this.stream,
    required this.startIcon,
    required this.movingIcon,
    this.endIcon,
    this.endPoint,
    this.polylineColor,
    this.polylineLiveColor,
    this.polyLineWidth,
    this.polyLineLiveWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveTrackingProvider);
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: state.currentPosition?.toLatLng() ?? LatLng(0, 0),
        zoom: 2,
      ),
      onMapCreated: (controller) async {
        ref.read(liveTrackingProvider.notifier).mapController = controller;
        ref.read(liveTrackingProvider.notifier)
            .initialize(
              stream: stream,
              startIcon: startIcon,
              endIcon: endIcon,
              endPoint: endPoint,
              movingIcon: movingIcon,
            );
        final firstPosition = await stream.first;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(firstPosition.lat, firstPosition.lng),
              zoom: 16,
            ), // LatLng(30.55549,  31.70253)
          ),
        );
      },
      markers: {
        if (state.startMarker != null) state.startMarker!,
        if (state.endMarker != null) state.endMarker!,
        if (state.movingMarker != null) state.movingMarker!,
      },
      polylines: {
        if (endPoint != null &&
            endIcon != null &&
            state.traveledPath.isNotEmpty)
          Polyline(
            polylineId: const PolylineId('actual_path'),
            points: [state.traveledPath.first.toLatLng(), endPoint!.toLatLng()],
            color: polylineColor ?? Colors.blue,
            width: polyLineWidth ?? 10,
          ),
        if (state.traveledPath.isNotEmpty)
          Polyline(
            polylineId: const PolylineId('live_path'),
            points: state.traveledPath.map((geo) => geo.toLatLng()).toList(),
            color: polylineLiveColor ?? Colors.red,
            width: polyLineLiveWidth ?? 5,
          ),
      },
    );
  }
}
