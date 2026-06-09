import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
import 'package:live_map_tracking/src/core/utils/custom_dot_loader.dart';
import 'package:live_map_tracking/src/core/utils/latlng_tween.dart';

typedef LocationStream = Stream<Position>;
typedef PermissionChecker = Future<void> Function();

class TrackingZone extends ConsumerStatefulWidget {
  const TrackingZone({
    super.key,
    required this.apiKey,
    required this.destinationLocation,
    required this.sourceIcon,
    required this.destinationIcon,
    required this.locationStream,
    required this.checkPermission,
  });
  final String apiKey;
  final GeoPoint destinationLocation;
  final String sourceIcon;
  final String destinationIcon;
  final LocationStream locationStream;
  final PermissionChecker checkPermission;

  @override
  ConsumerState<TrackingZone> createState() => _TrackingZoneState();
}

class _TrackingZoneState extends ConsumerState<TrackingZone>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  List<LatLng> _polylineCoordinates = [];
  LatLng? _currentLocation;
  LatLng? _previousLocation;
  late AnimationController _markerAnimationController;
  StreamSubscription<Position>? _locationSubscription;
  String _mapStyle = '';
  bool _markersInitialized = false;
  bool _isNearDestination = false;
  double _currentZoom = 13.5;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMapStyle();
    _initAnimation();
  }

  void _initAnimation() {
    _markerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _initLocation() async {
    try {
      await widget.checkPermission();
      debugPrint('Permission granted');
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint(
        'FIRST LOCATION => ${currentPosition.latitude}, ${currentPosition.longitude}',
      );
      _onLocationUpdate(currentPosition);

      // Then listen for updates
      _locationSubscription = widget.locationStream.listen(
        (position) {
          debugPrint(
            'TRACKING STREAM => ${position.latitude}, ${position.longitude}',
          );
          _onLocationUpdate(position);
        },
        onError: (e) {
          debugPrint('Location Stream Error: $e');
        },
      );
    } catch (e, s) {
      debugPrint('Permission Error: $e');
      debugPrint('$s');
    }
  }

  void _onLocationUpdate(Position position) async {
    try {
      debugPrint('LOCATION RECEIVED');

      final newLocation = LatLng(position.latitude, position.longitude);

      if (_currentLocation == null) {
        _currentLocation = newLocation;
        _previousLocation = newLocation;

        await _setInitialMarkers();

        debugPrint('MARKERS CREATED');

        setState(() {});
        return;
      }
      _previousLocation = _currentLocation;
      _currentLocation = newLocation;

      _animateMarker();
      _getPolyline(newLocation);
      _moveCamera(newLocation);
    } catch (e, s) {
      debugPrint('LOCATION UPDATE ERROR => $e');
      debugPrint('$s');
    }
  }

  Future<void> _setInitialMarkers() async {
    if (_markersInitialized) return;

    final sourceMarker = await LiveMapTracking.displayMarker(
      markerId: 'source',
      position: GeoPoint(
        lat: _currentLocation!.latitude,
        lng: _currentLocation!.longitude,
      ),
      assetIcon: widget.sourceIcon,
      iconWidth: 60,
      iconHeight: 60,
    );

    final destinationMarker = await LiveMapTracking.displayMarker(
      markerId: 'destination',
      position: GeoPoint(
        lat: widget.destinationLocation.lat,
        lng: widget.destinationLocation.lng,
      ),
      assetIcon: widget.destinationIcon,
      iconWidth: 80,
      iconHeight: 80,
    );

    _markers = {sourceMarker, destinationMarker};
    _markersInitialized = true;
  }

  void _animateMarker() {
    late Animation<LatLng> animation;

    animation = LatLngTween(
      begin: _previousLocation!,
      end: _currentLocation!,
    ).animate(_markerAnimationController);

    animation.addListener(() {
      _updateSourceMarker(animation.value);
    });

    _markerAnimationController.forward(from: 0);
  }

  void _updateSourceMarker(LatLng position) {
    final sourceMarker = _markers.firstWhere(
      (m) => m.markerId.value == 'source',
    );

    setState(() {
      _markers = {
        sourceMarker.copyWith(positionParam: position),
        ..._markers.where((m) => m.markerId.value != 'source'),
      };
    });
  }

  Future<void> _getPolyline(LatLng source) async {
    final distance = Geolocator.distanceBetween(
      source.latitude,
      source.longitude,
      widget.destinationLocation.lat,
      widget.destinationLocation.lng,
    );

    if (distance <= 10) {
      if (!_isNearDestination) {
        _isNearDestination = true;
        _polylineCoordinates.clear();
        setState(() {});
      }
      return;
    }

    if (_isNearDestination && distance > 10) {
      _isNearDestination = false;
    }

    final polylinePoints = PolylinePoints(apiKey: widget.apiKey);

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(source.latitude, source.longitude),
        destination: PointLatLng(
          widget.destinationLocation.lat,
          widget.destinationLocation.lng,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      _polylineCoordinates = result.points
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();

      setState(() {});
    }
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await DefaultAssetBundle.of(
        context,
      ).loadString('packages/live_map_tracking/assets/map_style.json');
    } catch (e) {
      debugPrint('Map Style Error: $e');
    }
  }

  Future<void> _moveCamera(LatLng target) async {
    if (!_controller.isCompleted) return;

    final controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: _currentZoom),
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocation == null) {
      return const Center(child: CustomDotProgressIndicator());
    }
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentLocation!,
        zoom: 13.5,
      ),
      markers: _markers,
      onCameraIdle: () async {
        final controller = await _controller.future;
        _currentZoom = await controller.getZoomLevel();
      },

      polylines: {
        Polyline(
          polylineId: const PolylineId('route'),
          points: _polylineCoordinates,
          width: 4,
          color: const Color(0xff252B37),
        ),
      },
      onMapCreated: (controller) {
        debugPrint('MAP CREATED');
        controller.setMapStyle(_mapStyle);
        _controller.complete(controller);
      },
    );
  }
}
