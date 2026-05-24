import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';

/// Client-side KYC checks — mirrors web `kycClientValidators.js` and backend `kyc_media.py`.
enum KycKind { idFront, idBack, selfie }

const int kycMaxBytes = 12 * 1024 * 1024;
const int kycMinBytes = 800;

const int _minPxId = 160000;
const int _minPxSelfie = 100000;
const int _minShortId = 260;
const int _minLongId = 380;
const int _minShortSelfie = 240;
const int _minLongSelfie = 300;
const double _idAspectMin = 1.12;
const double _idAspectMax = 3.4;

final RegExp _imageExt = RegExp(
  r'\.(jpe?g|png|webp|gif|bmp|tiff?|heic|heif|avif)$',
  caseSensitive: false,
);

/// Maps upload-step keys from [KycUploadScreen] to API slot kinds.
KycKind? kycKindForStepKey(String key) {
  switch (key) {
    case 'id_front':
      return KycKind.idFront;
    case 'id_back':
    case 'agency':
      return KycKind.idBack;
    case 'selfie':
      return KycKind.selfie;
    default:
      return null;
  }
}

bool isImageXFile(XFile file) {
  final mime = (file.mimeType ?? '').split(';').first.trim().toLowerCase();
  if (mime.startsWith('image/')) return true;
  if (mime.isEmpty || mime == 'application/octet-stream') {
    return _imageExt.hasMatch(file.path);
  }
  return false;
}

String? _validateIdFraming(int w, int h) {
  final aspect = w / h;
  if (h >= w * 1.05) {
    return 'This looks like a portrait photo, not an ID. Hold the phone sideways and photograph the flat card (landscape).';
  }
  if (aspect < _idAspectMin) {
    return 'This does not look like an ID card. Show the full card in landscape.';
  }
  if (aspect > _idAspectMax) {
    return 'Image is too wide and thin for an ID. Center the full card in the frame.';
  }
  return null;
}

String? _validateSelfieFraming(int w, int h) {
  if (w > h * 1.2) {
    return 'This looks like a document photo, not a selfie. Hold the phone vertically and photograph your face.';
  }
  if (h < w * 0.92) {
    return 'Selfie must be portrait (taller than wide). Do not upload a photo of your ID on a table.';
  }
  return null;
}

Future<({int width, int height, bool failed})> _loadImageDimensions(XFile file) async {
  try {
    final bytes = await file.readAsBytes();
    if (bytes.length < kycMinBytes) {
      return (width: 0, height: 0, failed: true);
    }
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final w = frame.image.width;
    final h = frame.image.height;
    frame.image.dispose();
    if (w < 1 || h < 1) return (width: 0, height: 0, failed: true);
    return (width: w, height: h, failed: false);
  } catch (_) {
    return (width: 0, height: 0, failed: true);
  }
}

/// Returns an error message, or `null` if the file passes checks.
Future<String?> validateKycFile(XFile file, KycKind kind) async {
  if (!isImageXFile(file)) {
    return 'Upload a photo (JPEG, PNG, WebP, HEIC, GIF, BMP, TIFF, etc.) — not PDF or other document types.';
  }

  final length = await file.length();
  if (length > kycMaxBytes) {
    return 'File is too large (max ${kycMaxBytes ~/ (1024 * 1024)} MB).';
  }
  if (length < kycMinBytes) {
    return 'File is too small to be a real photo.';
  }

  final dims = await _loadImageDimensions(file);
  if (dims.failed || dims.width < 1 || dims.height < 1) {
    return 'Could not read this as an image. Try another photo from your camera or gallery.';
  }

  final w = dims.width;
  final h = dims.height;
  final pixels = w * h;
  final shortE = w < h ? w : h;
  final longE = w > h ? w : h;

  switch (kind) {
    case KycKind.idFront:
    case KycKind.idBack:
      if (pixels < _minPxId) {
        return 'ID image is too small — fill the frame with your ID so text is readable.';
      }
      if (shortE < _minShortId || longE < _minLongId) {
        return 'ID photo is too low resolution. Move closer or retake in better light.';
      }
      return _validateIdFraming(w, h);
    case KycKind.selfie:
      if (pixels < _minPxSelfie) {
        return 'Selfie is too small — use your front camera and fill the frame with your face.';
      }
      if (shortE < _minShortSelfie || longE < _minLongSelfie) {
        return 'Selfie resolution is too low. Retake with your face and shoulders visible.';
      }
      return _validateSelfieFraming(w, h);
  }
}
