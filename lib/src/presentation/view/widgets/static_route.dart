import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';


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
    final markers = <Marker>{
      await LiveMapTracking.displayMarker(
        markerId: "start",
        position: GeoPoint(lat: start.latitude, lng: start.longitude),
        assetIcon: widget.statIcon,
        iconWidth: widget.iconWidth,
        iconHeight:widget.iconHeight ,
        onTap: () {
          notifier.selectMarker(
            Marker(markerId: const MarkerId("start"), position: start),
            start,
          );
        },
      ),
      await LiveMapTracking.displayMarker(
        markerId: "end",
        position: GeoPoint(lat: end.latitude, lng: end.longitude),
        assetIcon: widget.endIcon,
        iconWidth: widget.iconWidth,
        iconHeight:widget.iconHeight ,
        onTap: () {
          notifier.selectMarker(
            Marker(markerId: const MarkerId("end"), position: end),
            end,
          );
        },
      ),
    };

    notifier.setMarkers(markers);
  }

  @override
  Widget build(BuildContext context) {
    final startPoint = latLngPoints.first;
    Polyline tripPolyline = displayPolyLine();
    final markerState = ref.watch(markerStateProvider);
    return  Stack(
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
            polylines: {tripPolyline},
          ),
          if (markerState.selectedMarker != null &&
              markerState.selectedPosition != null)
            CustomInfoWindow(
              position: markerState.selectedPosition!,
              mapController: _mapController,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    Expanded(
                      child: Text(
                        "Marker: ${markerState.selectedMarker!.markerId.value}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
        ],
    );
  }

  Polyline displayPolyLine() {
    final Polyline tripPolyline = Polyline(
      polylineId: const PolylineId("trip_route"),
      color: widget.color ?? Colors.blue,
      width: widget.polyLineWidth ?? 5,
      points: latLngPoints,
    );
    return tripPolyline;
  }
}
