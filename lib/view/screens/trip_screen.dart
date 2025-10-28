import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripMapScreen extends StatefulWidget {
  final List<LatLng> actualPath;
  final List<LatLng> userPath;
  const TripMapScreen({super.key, required this.actualPath, required this.userPath});

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    final startPoint = widget.actualPath.first;
    final endPoint = widget.actualPath.last;

    Polyline tripPolyline = displayPolyLine();
    Polyline tripPolyline2 = displayPolyLine2();

    Set<Marker> markers = displayMarkers(startPoint, endPoint);

    return Scaffold(
      appBar: AppBar(title: const Text("Trip Route")),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: startPoint, zoom: 14),
            ),
          );
        },
        initialCameraPosition: CameraPosition(target: startPoint, zoom: 10),
        markers: markers,
        polylines: {tripPolyline,tripPolyline2},
      ),
    );
  }

  Set<Marker> displayMarkers(LatLng startPoint, LatLng endPoint) {
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId("start"),
        position: startPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: "Start"),
      ),
      Marker(
        markerId: const MarkerId("end"),
        position: endPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "End"),
      ),
    };
    return markers;
  }

  Polyline displayPolyLine() {
    final Polyline tripPolyline = Polyline(
      polylineId: const PolylineId("trip_route"),
      color: Colors.blue,
      width: 5,
      points: widget.actualPath,
    );
    return tripPolyline;
  }

  Polyline displayPolyLine2() {
    final Polyline tripPolyline = Polyline(
      polylineId: const PolylineId("trip_route2"),
      color: Colors.red,
      width: 5,
      points: widget.userPath,
    );
    return tripPolyline;
  }
}
