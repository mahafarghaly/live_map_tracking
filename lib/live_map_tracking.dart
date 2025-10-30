import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/src/core/utils/bitmap_helper.dart';
import 'package:live_map_tracking/src/data/models/geo_points.dart';

import 'live_map_tracking.dart';

export 'src/presentation/view/screens/static_route.dart';
export 'src/data/models/geo_points.dart';
export 'src/presentation/controllers/marker_controller.dart';
export 'src/presentation/view/widgets/custom_info_window.dart';

class LiveMapTracking {
  static Future<Marker> displayMarker({
    required String markerId,
    required GeoPoint position,
    required String assetIcon,
    VoidCallback? onTap,
    double? iconWidth,
    double? iconHeight,
  }) async {
    final customIcon =  BitmapDescriptor.bytes(
      await Utils.getImageFromRowData(image: assetIcon, width: iconWidth??48, height: iconHeight??48)
    );
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: position.toLatLng(),
      icon: customIcon,
      infoWindow: InfoWindow.noText,
      onTap: onTap,
    );

    return marker;
  }
}
