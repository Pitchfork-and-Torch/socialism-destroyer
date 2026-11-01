import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import 'binary_download_stub.dart'
    if (dart.library.html) 'binary_download_web.dart' as download;

/// Share or download binary files with web-safe fallbacks.
abstract final class BinaryShare {
  /// On web: downloads the file (share sheets are unreliable for blobs).
  /// On native: opens the system share sheet.
  static Future<String> shareOrDownloadPng({
    required Uint8List bytes,
    required String filename,
    String? shareText,
  }) async {
    if (kIsWeb) {
      download.downloadBytes(
        bytes: bytes,
        filename: filename,
        mimeType: 'image/png',
      );
      return 'downloaded';
    }

    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: filename,
          mimeType: 'image/png',
          length: bytes.length,
        ),
      ],
      text: shareText,
    );
    return 'shared';
  }
}
