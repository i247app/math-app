import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';

/// Upload only freshly encoded pixels, never the source file's EXIF/XMP data.
/// Animated avatars use their first frame. Decode failures must not fall back
/// to uploading the original file.
Future<MultipartFile> sanitizedAvatarUpload(String path) async {
  final source = await File(path).readAsBytes();
  final codec = await ui.instantiateImageCodec(source);
  ui.Image? image;
  try {
    image = (await codec.getNextFrame()).image;
    final encoded = await image.toByteData(format: ui.ImageByteFormat.png);
    if (encoded == null) {
      throw const FormatException('Unable to prepare avatar for upload.');
    }
    return MultipartFile.fromBytes(
      encoded.buffer.asUint8List(encoded.offsetInBytes, encoded.lengthInBytes),
      filename: 'avatar.png',
      contentType: DioMediaType('image', 'png'),
    );
  } finally {
    image?.dispose();
    codec.dispose();
  }
}
