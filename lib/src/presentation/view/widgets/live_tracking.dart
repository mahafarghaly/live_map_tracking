import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
import 'package:live_map_tracking/src/core/utils/app_utils.dart';
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
        final notifier = ref.read(liveTrackingProvider.notifier);
        notifier.mapController = controller;
        final firstPosition = await stream.first;
        if (state.movingMarker != null && state.traveledPath.isNotEmpty) {
          updateCameraPosition(controller, firstPosition);
          return;
        }
        await notifier.initialize(
          stream: stream,
          startIcon: startIcon,
          endIcon: endIcon,
          endPoint: endPoint,
          movingIcon: movingIcon,
        );
        updateCameraPosition(controller, firstPosition);
      },
      markers: {
        if (state.startMarker != null) state.startMarker!,
        if (state.endMarker != null) state.endMarker!,
        if (state.movingMarker != null) state.movingMarker!,
      },
      polylines: {
        if (state.actualPolyline.isNotEmpty)
        Utils.displayPolyLine(polylineId: 'actual_path', points: state.actualPolyline,  color: polylineColor,width: polyLineWidth),
        if (state.traveledPath.isNotEmpty)
        Utils.displayPolyLine(polylineId: 'live_path', points: state.traveledPath.map((geo) => geo.toLatLng()).toList(),  color: polylineLiveColor,width: polyLineLiveWidth),
      },
    );
  }

  void updateCameraPosition(GoogleMapController controller, GeoPoint firstPosition) {
          controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(firstPosition.lat, firstPosition.lng),
          zoom: 16,
        ),
      ),
    );
  }
}

