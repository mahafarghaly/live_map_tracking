import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
import 'package:live_map_tracking/src/core/utils/utils.dart';
import 'package:live_map_tracking/src/presentation/view/screens/search_one_place.dart';

import '../../controllers/search_controller.dart';
import 'search_routes_screen.dart';

class SearchOnMap extends ConsumerStatefulWidget {
  final String apiKey;
  final GeoPoint currentLocation;
  final GeoPoint initialCameraPosition;
  final String? statIcon;
  final String? endIcon;
  final String? pinIcon;
  final Color? color;
  final int? polyLineWidth;
  final double? iconHeight;
  final double? iconWidth;
  final bool? enableRoute;
  final String? hintText;
  final Widget? prefixSearchIcon;
  final Widget? suffixSearchIcon;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Function(String address, GeoPoint location)? onPlaceSelected;

  const SearchOnMap({
    super.key,
    required this.apiKey,
    required this.currentLocation,
    this.statIcon,
    this.endIcon,
    this.color,
    this.polyLineWidth,
    this.iconHeight,
    this.iconWidth,
    this.onPlaceSelected,
    this.enableRoute,
    this.pinIcon,
    required this.initialCameraPosition,
    this.hintText,
    this.prefixSearchIcon,
    this.suffixSearchIcon,
    this.hintStyle,
    this.textStyle,
  });

  @override
  ConsumerState<SearchOnMap> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<SearchOnMap> {
  GoogleMapController? _controller;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  String mapStyle = "";
  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _setInitialMarker();
  }

  Future<void> _setInitialMarker() async {
    final initialMarker = await LiveMapTracking.displayMarker(
      markerId: 'initial',
      position: widget.currentLocation,
      assetIcon: widget.pinIcon,
      iconHeight: widget.iconHeight,
      iconWidth: widget.iconWidth,
    );
    if (!mounted) return;
    if (widget.currentLocation.lat != 0 || widget.currentLocation.lng != 0) {
      setState(() {
        _markers = {initialMarker};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocation =
        widget.currentLocation.lat != 0.0 && widget.currentLocation.lng != 0.0;
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          initialCameraPosition: isLocation
              ? CameraPosition(
                  target: widget.currentLocation.toLatLng(),
                  zoom: 10,
                )
              : CameraPosition(
                  target: widget.initialCameraPosition
                      .toLatLng(), // LatLng( 39.8283, -98.5795,),
                  zoom: 4,
                ),
          onMapCreated: (controller) async {
            _controller = controller;
            if (mapStyle.isNotEmpty) {
              await _controller!.setMapStyle(mapStyle);
            }
            if (isLocation) {
              await _controller!.animateCamera(
                CameraUpdate.newLatLngZoom(
                  widget.currentLocation.toLatLng(),
                  12,
                ),
              );
            }
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
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xffD5D7DA)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  Text(
                    widget.hintText ?? "Search for location",
                    style:
                        widget.textStyle ??
                        TextStyle(
                          color: Color(0xff252B37),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                  ),
                  Spacer(),
                  if (widget.suffixSearchIcon != null) widget.suffixSearchIcon!,
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
      MaterialPageRoute(
        builder: (_) => SearchRoutesScreen(apiKey: widget.apiKey),
      ),
    );

    if (result is Map) {
      final origin =
          result['origin'] as LatLng? ?? widget.currentLocation.toLatLng();
      final destination = result['destination'] as LatLng;

      await _drawRoute(widget.apiKey, origin, destination);
    }
  }

  Future<void> _onSearchTap() async {
    ref.read(searchControllerProvider(widget.apiKey).notifier).reset();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchOnePlaceScreen(
          hintText: widget.hintText,
          hintStyle: widget.hintStyle,
          prefixSearchIcon: widget.prefixSearchIcon,
          suffixSearchIcons: widget.suffixSearchIcon,
          textStyle: widget.textStyle,
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
              CameraUpdate.newLatLngZoom(location.toLatLng(), 12),
            );

            if (widget.onPlaceSelected != null) {
              widget.onPlaceSelected!(address, location);
            }
          },
        ),
      ),
    );
  }

  Future<void> _drawRoute(
    String apiKey,
    LatLng origin,
    LatLng destination,
  ) async {
    final result = await ref
        .read(searchControllerProvider(widget.apiKey).notifier)
        .drawRoutePolyline(apiKey, origin, destination);
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

  Future<void> _loadMapStyle() async {
    mapStyle = await DefaultAssetBundle.of(
      context,
    ).loadString('packages/live_map_tracking/assets/map_style.json');
  }
}
