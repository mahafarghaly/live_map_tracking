import 'dart:ui' as ui;
import 'package:flutter/services.dart';

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
}
