import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
import 'package:live_map_tracking/src/core/network/api_constants.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:live_map_tracking/src/core/utils/app_utils.dart';

import '../../controllers/search_controller.dart';
import '../screens/search_screen.dart';

class SearchOnMap extends ConsumerStatefulWidget {
  final GeoPoint location;
  final String statIcon;
  final String endIcon;
  final Color? color;
  final int? polyLineWidth;
  final double? iconHeight;
  final double? iconWidth;

  const SearchOnMap({
    super.key,
    required this.location,
    required this.statIcon,
    required this.endIcon,
    this.color,
    this.polyLineWidth,
    this.iconHeight,
    this.iconWidth,
  });

  @override
  ConsumerState<SearchOnMap> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<SearchOnMap> {
  GoogleMapController? _controller;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Future<void> _onSearchTap() async {
    ref.read(searchControllerProvider.notifier).reset();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPlacesScreen()),
    );

    if (result is Map) {
      final origin = result['origin'] as LatLng? ?? widget.location.toLatLng();
      final destination = result['destination'] as LatLng;

      await _drawRoute(origin, destination);
    }
  }

  Future<void> _drawRoute(LatLng origin, LatLng destination) async {
    final result = await ref
        .read(searchControllerProvider.notifier)
        .drawRoutePolyline(origin, destination);
    if (result.isNotEmpty) {
      final points = result
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
      final markersSet = await displayMarkers(origin, destination);
      setState(() {
        _polylines = {
          Utils.displayPolyLine(polylineId: 'route', points: points,width:widget.polyLineWidth,color: widget.color)
        };
        _markers = markersSet;
      });
      await _controller?.animateCamera(CameraUpdate.newLatLngZoom(origin, 8));
    }
  }

  Future<Set<Marker>> displayMarkers(LatLng origin, LatLng destination) async {
    final originMarker = await LiveMapTracking.displayMarker(
      markerId: 'origin',
      position: GeoPoint(lat: origin.latitude, lng: origin.longitude),
      assetIcon: widget.statIcon,
      iconHeight: widget.iconHeight,
      iconWidth: widget.iconWidth,
    );
    final destinationMarker = await LiveMapTracking.displayMarker(
      markerId: 'destination',
      position: GeoPoint(lat: destination.latitude, lng: destination.longitude),
      assetIcon: widget.endIcon,
      iconHeight: widget.iconHeight,
      iconWidth: widget.iconWidth,
    );
    return {originMarker, destinationMarker};
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: widget.location.toLatLng(), zoom: 10),
          onMapCreated: (controller) {
            _controller = controller;
          },
          polylines: _polylines,
          markers: _markers,
        ),
        SafeArea(
          child: GestureDetector(
            onTap: _onSearchTap,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text("Search for a route..."),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
