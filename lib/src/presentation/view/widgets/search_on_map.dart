import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/src/core/network/api_constants.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../controllers/search_controller.dart';
import '../screens/search_screen.dart';
class SearchOnMap extends ConsumerStatefulWidget {
  const SearchOnMap({super.key});

  @override
  ConsumerState<SearchOnMap> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<SearchOnMap> {
  GoogleMapController? _controller;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  LatLng _myLocation = const LatLng(30.0444, 31.2357);

  Future<void> _onSearchTap() async {
    ref.read(searchControllerProvider.notifier).reset();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPlacesScreen()),
    );

    if (result is Map) {
      final origin = result['origin'] as LatLng? ?? _myLocation;
      final destination = result['destination'] as LatLng;

      await _drawRoute(origin, destination);
    }
  }

  Future<void> _drawRoute(LatLng origin, LatLng destination) async {
    final polylinePoints = PolylinePoints(apiKey: ApiConstants.apiKey);
    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin:PointLatLng(origin.latitude, origin.longitude),
        destination:    PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
      ),


    );

    if (result.points.isNotEmpty) {
      final points = result.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 5,
          ),
        };
        _markers = {
          Marker(markerId:  MarkerId('origin'), position: origin,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
          ),
          Marker(markerId: const MarkerId('destination'), position: destination),
        };
     });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
            CameraPosition(target: _myLocation, zoom: 8),
            onMapCreated: (c) => _controller = c,
            polylines: _polylines,
            markers: _markers,
          ),
          SafeArea(
            child: GestureDetector(
              onTap:_onSearchTap,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
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
