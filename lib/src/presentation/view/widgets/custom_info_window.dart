import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../live_map_tracking.dart';

class CustomInfoWindow extends ConsumerWidget {
  final LatLng position;
  final Widget child;
  final GoogleMapController mapController;
  final double infoWidth;
  final double infoHeight;
  final double
  markerAnchorOffset; // how many pixels above the marker bottom

  const CustomInfoWindow({
    required this.position,
    required this.child,
    required this.mapController,
    this.infoWidth = 180,
    this.infoHeight = 90,
    this.markerAnchorOffset = 48,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = mapController.getScreenCoordinate(position);
    return FutureBuilder<ScreenCoordinate>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();

        final screenCoordinate = snap.data!;
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final double logicalX = screenCoordinate.x / dpr;
        final double logicalY = screenCoordinate.y / dpr;
        final left = logicalX - (infoWidth / 2);
        final top = logicalY - markerAnchorOffset - infoHeight;
        final screenW = MediaQuery.of(context).size.width;
        final clampedLeft = left.clamp(8.0, screenW - infoWidth - 8.0);

        return Positioned(
          left: clampedLeft,
          top: top.clamp(8.0, double.infinity),
          width: infoWidth,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: [
                Align(
                  alignment: AlignmentGeometry.topRight,
                  child: IconButton(
                    onPressed: () {
                      ref.read(markerStateProvider.notifier).clearSelection();
                    },
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                  ),
                ),
                Container(
                  height: infoHeight,
                  padding: const EdgeInsets.all(8),
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
