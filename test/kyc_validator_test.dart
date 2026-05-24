import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rental_mgr_mobile/core/kyc/kyc_validator.dart';

void main() {
  group('kycKindForStepKey', () {
    test('maps API slots', () {
      expect(kycKindForStepKey('id_front'), KycKind.idFront);
      expect(kycKindForStepKey('id_back'), KycKind.idBack);
      expect(kycKindForStepKey('agency'), KycKind.idBack);
      expect(kycKindForStepKey('selfie'), KycKind.selfie);
      expect(kycKindForStepKey('property'), isNull);
    });
  });

  group('isImageXFile', () {
    test('accepts image mime', () {
      expect(
        isImageXFile(XFile.fromData(Uint8List(1000), mimeType: 'image/jpeg', name: 'x.bin')),
        isTrue,
      );
    });

    test('accepts known extension when mime missing', () {
      expect(isImageXFile(XFile('/tmp/photo.heic')), isTrue);
      expect(isImageXFile(XFile('/tmp/doc.pdf')), isFalse);
    });
  });
}
