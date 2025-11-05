import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';

import '../../../core/utils/utils.dart';

class StaticRoute extends ConsumerStatefulWidget {
  final List<GeoPoint> directionList;
  final String statIcon;
  final String endIcon;
  final Color? color;
  final int? polyLineWidth;
  final double? iconHeight;
  final double? iconWidth;

  const StaticRoute({
    super.key,
    required this.directionList,
    required this.statIcon,
    required this.endIcon,
    this.color,
    this.polyLineWidth,
    this.iconHeight,
    this.iconWidth,
  });

  @override
  ConsumerState<StaticRoute> createState() => _StaticRouteState();
}

class _StaticRouteState extends ConsumerState<StaticRoute> {
  late GoogleMapController _mapController;
  late List<LatLng> latLngPoints;

  @override
  void initState() {
    super.initState();
    latLngPoints = widget.directionList.map((p) => p.toLatLng()).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadMarkers();
    });
  }

  Future<void> _loadMarkers() async {
    final notifier = ref.read(markerStateProvider.notifier);
    final start = latLngPoints.first;
    final end = latLngPoints.last;
    late Marker startMarker;
    late Marker endMarker;
    startMarker = await LiveMapTracking.displayMarker(
      markerId: "start",
      position: GeoPoint(lat: start.latitude, lng: start.longitude),
      assetIcon: widget.statIcon,
      iconWidth: widget.iconWidth,
      iconHeight: widget.iconHeight,
      onTap: () {
        notifier.selectMarker(startMarker);
      },
    );
    endMarker = await LiveMapTracking.displayMarker(
      markerId: "end",
      position: GeoPoint(lat: end.latitude, lng: end.longitude),
      assetIcon: widget.endIcon,
      iconWidth: widget.iconWidth,
      iconHeight: widget.iconHeight,
      onTap: () {
        notifier.selectMarker(endMarker);
      },
    );
    final markers = <Marker>{startMarker, endMarker};

    notifier.setMarkers(markers);
  }

  @override
  Widget build(BuildContext context) {
    final startPoint = latLngPoints.first;
    final markerState = ref.watch(markerStateProvider);
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            _mapController = controller;
            _mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: startPoint, zoom: 14),
              ),
            );
          },
          onTap: (_) => ref.read(markerStateProvider.notifier).clearSelection(),
          initialCameraPosition: CameraPosition(target: startPoint, zoom: 10),
          markers: markerState.markers,
          polylines: displayPolyLine(),
        ),
        if (markerState.selectedMarker != null)
          CustomInfoWindow(
            position: markerState.selectedMarker!.position,
            mapController: _mapController,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Expanded(
                    child: Text(
                      "Marker: ${markerState.selectedMarker!.markerId.value}\n"
                      "latitude: ${markerState.selectedMarker?.position.latitude}\n"
                      "longitude: ${markerState.selectedMarker?.position.longitude}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Set<Polyline> displayPolyLine() {
    final Polyline tripPolyline =
    Utils.displayPolyLine(polylineId: "trip_route", points:latLngPoints,  color:widget.color,width: widget.polyLineWidth);
    return {tripPolyline};
  }

}
