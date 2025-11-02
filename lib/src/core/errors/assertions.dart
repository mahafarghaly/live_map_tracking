import 'package:live_map_tracking/live_map_tracking.dart';
void validateLiveTrackingInputs({
  String? endIcon,
  GeoPoint? endPoint,
}) {
  if ((endIcon != null && endPoint == null) ||
      (endPoint != null && endIcon == null)) {
    throw ArgumentError(
      'You must provide both endIcon and endPoint, or neither.',
    );
  }
}
