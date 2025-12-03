import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
import 'package:live_map_tracking/src/core/utils/utils.dart';
import 'package:live_map_tracking/src/presentation/view/screens/search_one_place.dart';

import '../../controllers/search_controller.dart';
import '../screens/search_routes_screen.dart';

class SearchOnMap extends ConsumerStatefulWidget {
  final String apiKey;
  final GeoPoint location;
  final String? statIcon;
  final String? endIcon;
  final String? pinIcon;
  final Color? color;
  final int? polyLineWidth;
  final double? iconHeight;
  final double? iconWidth;
  final bool? enableRoute;
  final Function(String address, GeoPoint location)? onPlaceSelected;

  const SearchOnMap({
    super.key,
    required this.apiKey,
    required this.location,
    this.statIcon,
    this.endIcon,
    this.color,
    this.polyLineWidth,
    this.iconHeight,
    this.iconWidth,
    this.onPlaceSelected,
    this.enableRoute,
    this.pinIcon,
  });

  @override
  ConsumerState<SearchOnMap> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<SearchOnMap> {
  GoogleMapController? _controller;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          initialCameraPosition: CameraPosition(
            target: widget.location.toLatLng(),
            zoom: 10,
          ),
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
                  Text("Search for location"),
                ],
              ),
            ),
          ),
        ),
        if (widget.enableRoute == true)
          Positioned(
            right: 14,
            bottom: 40,
            child: FloatingActionButton(
              backgroundColor: Colors.teal,
              onPressed: _onRouteTap,
              child: Icon(Icons.directions, color: Colors.white, size: 30),
            ),
          ),
      ],
    );
  }

  Future<void> _onRouteTap() async {
    ref.read(searchControllerProvider(widget.apiKey).notifier).reset();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) =>  SearchRoutesScreen(apiKey:widget.apiKey,)),
    );

    if (result is Map) {
      final origin = result['origin'] as LatLng? ?? widget.location.toLatLng();
      final destination = result['destination'] as LatLng;

      await _drawRoute(widget.apiKey,origin, destination);
    }
  }

  Future<void> _onSearchTap() async {
    ref.read(searchControllerProvider(widget.apiKey).notifier).reset();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchOnePlaceScreen(
          apiKey: widget.apiKey,
          onPlaceSelected: (address, location) async {
            final originMarker = await LiveMapTracking.displayMarker(
              markerId: 'place',
              assetIcon: widget.pinIcon,
              position: location,
              iconHeight: widget.iconHeight,
              iconWidth: widget.iconWidth,
            );

            setState(() {
              _markers = {originMarker};
              _polylines = {};
            });

            await _controller?.animateCamera(
              CameraUpdate.newLatLngZoom(location.toLatLng(), 8),
            );

            if (widget.onPlaceSelected != null) {
              widget.onPlaceSelected!(address, location);
            }
          },
        ),
      ),
    );
  }

  Future<void> _drawRoute(String apiKey,LatLng origin, LatLng destination) async {
    final result = await ref
        .read(searchControllerProvider(widget.apiKey).notifier)
        .drawRoutePolyline(apiKey,origin, destination);
    if (result.isNotEmpty) {
      final points = result
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
      final markersSet = await displayMarkers(origin, destination);
      setState(() {
        _polylines = {
          Utils.displayPolyLine(
            polylineId: 'route',
            points: points,
            width: widget.polyLineWidth,
            color: widget.color,
          ),
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
}
