import 'dart:typed_data';

/// Non-web stub — downloads are not used outside the browser.
void downloadBytes({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) {
  throw UnsupportedError('File download is only available on web');
}
