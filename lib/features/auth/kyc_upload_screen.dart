import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rental_mgr_mobile/core/auth/kyc_draft_provider.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_flow_stepper.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

class KycUploadScreen extends ConsumerStatefulWidget {
  const KycUploadScreen({super.key, required this.roleLabel});

  final String roleLabel;

  @override
  ConsumerState<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends ConsumerState<KycUploadScreen> {
  final _picker = ImagePicker();
  int _step = 0;

  @override
  void initState() {
    super.initState();
    ref.read(kycDraftProvider.notifier).reset(widget.roleLabel);
  }

  bool get _isLandlord => widget.roleLabel == 'landlord';
  bool get _isAgent => widget.roleLabel == 'agent';

  List<_KycStep> get _steps {
    if (_isAgent) {
      return const [
        _KycStep('id_front', 'National ID', 'Clear photo of ID front.'),
        _KycStep('agency', 'Agency license', 'Valid agency registration.'),
        _KycStep('selfie', 'Selfie', 'Portrait matching your ID.'),
      ];
    }
    if (_isLandlord) {
      return const [
        _KycStep('id_front', 'National ID (front)', 'Government ID front.'),
        _KycStep('id_back', 'National ID (back)', 'Back of your ID.'),
        _KycStep('selfie', 'Selfie', 'Portrait, no sunglasses.'),
        _KycStep('property', 'Proof of address', 'Utility bill or ownership proof.'),
      ];
    }
    return const [];
  }

  Future<void> _pick(String key) async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) ref.read(kycDraftProvider.notifier).setFile(key, file);
  }

  void _next() {
    final steps = _steps;
    final s = steps[_step];
    final draft = ref.read(kycDraftProvider);
    final hasFile = switch (s.key) {
      'id_front' => draft.idFront != null,
      'id_back' || 'agency' => draft.idBack != null,
      'selfie' => draft.selfie != null,
      _ => true,
    };
    if (!hasFile && s.key != 'property') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload this document first')));
      return;
    }
    if (_step < steps.length - 1) {
      setState(() => _step++);
    } else {
      context.push(RouteNames.kycReview);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    if (steps.isEmpty) {
      return AuthPageScaffold(
        body: Center(child: Text('Tenants can skip KYC.', style: AppTextStyles.bodyMediumOnDark)),
      );
    }
    final s = steps[_step];
    final draft = ref.watch(kycDraftProvider);
    final file = switch (s.key) {
      'id_front' => draft.idFront,
      'id_back' || 'agency' => draft.idBack,
      'selfie' => draft.selfie,
      _ => null,
    };

    return AuthPageScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthFlowStepper(step: 6),
            const SizedBox(height: 20),
            Text('Identity verification', style: AppTextStyles.displayHero.copyWith(fontSize: 24)),
            Text(
              'Step ${_step + 1} of ${steps.length}',
              style: AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.textMutedOnDark),
            ),
            const SizedBox(height: 20),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.title, style: AppTextStyles.headingMedium),
                  const SizedBox(height: 8),
                  Text(s.subtitle, style: AppTextStyles.bodySmallOnDark),
                  const SizedBox(height: 16),
                  if (file != null) Text(file.name, style: AppTextStyles.captionOnDark),
                  OutlinedButton.icon(
                    onPressed: () => _pick(s.key),
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(file == null ? 'Upload' : 'Replace'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('Back')),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(_step < steps.length - 1 ? 'Next' : 'Review verification'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KycStep {
  const _KycStep(this.key, this.title, this.subtitle);
  final String key;
  final String title;
  final String subtitle;
}
