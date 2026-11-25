import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

/// Connects Flutter Web to the Tesseract.js helper in web/ocr_helper.js
/// (it defines window.recognizePassImage).
@JS('recognizePassImage')
external JSPromise<JSString> _recognizePassImage(JSString imageDataUrl);

class PassRecognitionService {
  PassRecognitionService._();

  /// false when the helper script is not loaded in web/index.html.
  static bool get isAvailable => globalContext.has('recognizePassImage');

  /// Reads image bytes and returns the text recognized by Tesseract.
  static Future<String> recognizeText(Uint8List imageBytes) async {
    if (imageBytes.isEmpty) {
      throw ArgumentError('The captured image is empty.');
    }

    final base64Image = base64Encode(imageBytes);
    final dataUrl = 'data:image/jpeg;base64,$base64Image';

    try {
      final result = await _recognizePassImage(dataUrl.toJS).toDart;

      return result.toDart;
    } catch (error) {
      throw Exception('OCR recognition failed: $error');
    }
  }
}