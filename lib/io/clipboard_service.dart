import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:pasteboard/pasteboard.dart';

import 'image_codecs.dart';

/// System clipboard access for images.
///
/// Uses PNG as the interchange format: it is the one encoding every Linux
/// desktop toolkit agrees on, and it keeps the alpha channel that BMP — the
/// other common choice — would drop.
abstract final class ClipboardService {
  /// The clipboard image, or null when it holds something else.
  static Future<ui.Image?> readImage() async {
    final Uint8List? bytes = await Pasteboard.image;
    if (bytes == null || bytes.isEmpty) return null;
    try {
      return await ImageCodecs.decodeBytes(bytes, filename: 'clipboard');
    } on ImageDecodeException {
      return null;
    }
  }

  /// Puts [image] on the clipboard.
  static Future<void> writeImage(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return;
    await Pasteboard.writeImage(data.buffer.asUint8List());
  }
}
