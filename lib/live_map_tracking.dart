import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/src/core/utils/utils.dart';
import 'package:live_map_tracking/src/data/models/geo_points.dart';
import 'live_map_tracking.dart';
export 'src/presentation/view/widgets/static_route.dart';
export 'src/data/models/geo_points.dart';
export 'src/presentation/controllers/marker_controller.dart';
export 'src/presentation/view/widgets/custom_info_window.dart';
export 'src/presentation/view/widgets/live_tracking.dart';
export 'src/presentation/view/screens/search_on_map.dart';

class LiveMapTracking {
  static Future<Marker> displayMarker({
    required String markerId,
    required GeoPoint position,
     String? assetIcon,
    VoidCallback? onTap,
    double? iconWidth,
    double? iconHeight,
  }) async {
    BitmapDescriptor icon;
    if (assetIcon != null && assetIcon.isNotEmpty) {
      try {
        icon = BitmapDescriptor.bytes(
          await Utils.getImageFromRowData(
            image: assetIcon,
            width: iconWidth ?? 48,
            height: iconHeight ?? 48,
          ),
        );
      } catch (e) {
        debugPrint('Failed to load custom icon: $e');
        icon = BitmapDescriptor.defaultMarker;
      }
    } else {
      icon = BitmapDescriptor.defaultMarker;
    }
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: position.toLatLng(),
      icon: icon,
      infoWindow: InfoWindow.noText,
      onTap: onTap,
    );

    return marker;
  }
}
