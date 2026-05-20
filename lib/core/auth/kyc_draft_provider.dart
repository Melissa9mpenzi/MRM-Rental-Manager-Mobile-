import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class KycDraft {
  const KycDraft({
    this.roleLabel = 'landlord',
    this.idFront,
    this.idBack,
    this.selfie,
    this.extraLabel,
  });

  final String roleLabel;
  final XFile? idFront;
  final XFile? idBack;
  final XFile? selfie;
  final String? extraLabel;

  bool get readyForApi => idFront != null && idBack != null && selfie != null;
}

class KycDraftNotifier extends StateNotifier<KycDraft> {
  KycDraftNotifier() : super(const KycDraft());

  void reset(String roleLabel) => state = KycDraft(roleLabel: roleLabel);

  void setFile(String key, XFile? file) {
    switch (key) {
      case 'id_front':
        state = KycDraft(
          roleLabel: state.roleLabel,
          idFront: file,
          idBack: state.idBack,
          selfie: state.selfie,
          extraLabel: state.extraLabel,
        );
      case 'id_back':
      case 'agency':
        state = KycDraft(
          roleLabel: state.roleLabel,
          idFront: state.idFront,
          idBack: file,
          selfie: state.selfie,
          extraLabel: key == 'agency' ? 'Agency license' : state.extraLabel,
        );
      case 'selfie':
        state = KycDraft(
          roleLabel: state.roleLabel,
          idFront: state.idFront,
          idBack: state.idBack,
          selfie: file,
          extraLabel: state.extraLabel,
        );
      case 'property':
        state = KycDraft(
          roleLabel: state.roleLabel,
          idFront: state.idFront,
          idBack: state.idBack,
          selfie: state.selfie,
          extraLabel: 'Property documents (local note)',
        );
    }
  }
}

final kycDraftProvider = StateNotifierProvider<KycDraftNotifier, KycDraft>((ref) {
  return KycDraftNotifier();
});
