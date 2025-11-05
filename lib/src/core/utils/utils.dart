import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Utils {
  static Future<Uint8List> getImageFromRowData({
    required String image,
    required double width,
    required double height,
  }) async {
    var imageData = await rootBundle.load(image);
    var imageCodec = await ui.instantiateImageCodec(
      imageData.buffer.asUint8List(),
      targetHeight: height.round(),
      targetWidth: width.round(),
    );
    var imageFrameInfo = await imageCodec.getNextFrame();
    var imageBytData = await imageFrameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return imageBytData!.buffer.asUint8List();
  }
  static Polyline displayPolyLine({required String polylineId,required List<LatLng>points,Color? color, int? width}){
    return Polyline(
      polylineId:  PolylineId(polylineId),
      points: points,
      color: color??Colors.blue,
      width: width ?? 5,
    );
  }
}
