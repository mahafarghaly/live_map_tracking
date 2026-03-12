import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Utils {
  static Future<Uint8List> getImageFromRowData({
    required String image,
    required double width,
    required double height,
  }) async {
    try {
      final svgString = await rootBundle.loadString(image);

      final pictureInfo = await vg.loadPicture(
        SvgStringLoader(svgString),
        null,
      );

      final picture = pictureInfo.picture;

      final img = await picture.toImage(width.toInt(), height.toInt());

      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      return byteData!.buffer.asUint8List();
    } catch (e) {
      throw Exception('Failed to convert SVG to image: $e');
    }
  }

  static Polyline displayPolyLine({
    required String polylineId,
    required List<LatLng> points,
    Color? color,
    int? width,
  }) {
    return Polyline(
      polylineId: PolylineId(polylineId),
      points: points,
      color: color ?? Colors.blue,
      width: width ?? 5,
    );
  }
}
