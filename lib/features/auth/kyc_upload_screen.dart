import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rental_mgr_mobile/core/auth/kyc_draft_provider.dart';
import 'package:rental_mgr_mobile/core/kyc/kyc_validator.dart';
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
  final Map<String, String> _slotErrors = {};
  bool _validating = false;

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
        _KycStep('id_front', 'National ID', 'Clear photo of ID front (landscape).', KycKind.idFront),
        _KycStep('agency', 'Agency license', 'Valid agency registration (landscape photo).', KycKind.idBack),
        _KycStep('selfie', 'Selfie', 'Portrait matching your ID — hold phone vertically.', KycKind.selfie),
      ];
    }
    if (_isLandlord) {
      return const [
        _KycStep('id_front', 'National ID (front)', 'Government ID front — landscape, card fills frame.', KycKind.idFront),
        _KycStep('id_back', 'National ID (back)', 'Back of your ID — landscape.', KycKind.idBack),
        _KycStep('selfie', 'Selfie', 'Portrait selfie, no sunglasses.', KycKind.selfie),
        _KycStep('property', 'Proof of address', 'Optional: utility bill or ownership proof (not sent to server).', null),
      ];
    }
    return const [];
  }

  Future<ImageSource?> _chooseSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(String key, KycKind? kind) async {
    final source = await _chooseSource();
    if (source == null) return;

    setState(() {
      _validating = true;
      _slotErrors.remove(key);
    });

    try {
      final file = await _picker.pickImage(source: source, imageQuality: 90);
      if (file == null) return;

      if (kind != null) {
        final err = await validateKycFile(file, kind);
        if (err != null) {
          if (!mounted) return;
          setState(() => _slotErrors[key] = err);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: AppColors.error),
          );
          return;
        }
      }

      ref.read(kycDraftProvider.notifier).setFile(key, file);
      if (mounted) setState(() => _slotErrors.remove(key));
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  Future<bool> _validateCurrentStep(_KycStep s) async {
    if (s.kind == null) return true;

    final draft = ref.read(kycDraftProvider);
    final file = switch (s.key) {
      'id_front' => draft.idFront,
      'id_back' || 'agency' => draft.idBack,
      'selfie' => draft.selfie,
      _ => null,
    };

    if (file == null) {
      setState(() => _slotErrors[s.key] = 'Upload this document first.');
      return false;
    }

    final err = await validateKycFile(file, s.kind!);
    if (err != null) {
      if (!mounted) return false;
      setState(() => _slotErrors[s.key] = err);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
      return false;
    }
    setState(() => _slotErrors.remove(s.key));
    return true;
  }

  Future<void> _next() async {
    final steps = _steps;
    final s = steps[_step];

    if (s.kind != null) {
      final ok = await _validateCurrentStep(s);
      if (!ok) return;
    }

    if (_step < steps.length - 1) {
      setState(() => _step++);
    } else {
      final draft = ref.read(kycDraftProvider);
      if (!draft.readyForApi) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add ID front, ID back, and a portrait selfie.')),
        );
        return;
      }
      for (final step in steps) {
        if (step.kind == null) continue;
        final ok = await _validateCurrentStep(step);
        if (!ok) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fix the issues on your documents before continuing.')),
          );
          return;
        }
      }
      if (!mounted) return;
      context.push(RouteNames.kycReview);
    }
  }

  String _hintForKind(KycKind? kind) {
    switch (kind) {
      case KycKind.idFront:
      case KycKind.idBack:
        return 'Use landscape: hold the phone sideways so the full ID card is sharp and readable.';
      case KycKind.selfie:
        return 'Use portrait: face and shoulders visible. Do not photograph your ID lying on a table.';
      default:
        return 'Optional local note only — not uploaded with KYC.';
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
    final slotError = _slotErrors[s.key];

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
            const SizedBox(height: 8),
            Text(
              'Photos are checked for type, size, and framing. Wrong slots (e.g. selfie as ID) are rejected before upload.',
              style: AppTextStyles.captionOnDark.copyWith(color: AppColors.textMutedOnDark),
            ),
            const SizedBox(height: 20),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.title, style: AppTextStyles.headingMedium),
                  const SizedBox(height: 8),
                  Text(s.subtitle, style: AppTextStyles.bodySmallOnDark),
                  const SizedBox(height: 6),
                  Text(_hintForKind(s.kind), style: AppTextStyles.captionOnDark.copyWith(color: AppColors.accentGreen.withValues(alpha: 0.85))),
                  const SizedBox(height: 16),
                  if (file != null)
                    Text(file.name, style: AppTextStyles.captionOnDark, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (slotError != null) ...[
                    const SizedBox(height: 8),
                    Text(slotError, style: AppTextStyles.captionOnDark.copyWith(color: AppColors.error)),
                  ],
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _validating ? null : () => _pick(s.key, s.kind),
                    icon: _validating
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload_file_outlined),
                    label: Text(_validating ? 'Checking…' : (file == null ? 'Upload' : 'Replace')),
                  ),
                  if (s.kind != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Max ${kycMaxBytes ~/ (1024 * 1024)} MB · JPEG, PNG, WebP, HEIC, etc.',
                        style: AppTextStyles.captionOnDark,
                        textAlign: TextAlign.center,
                      ),
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
                    onPressed: _validating ? null : _next,
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
  const _KycStep(this.key, this.title, this.subtitle, this.kind);
  final String key;
  final String title;
  final String subtitle;
  final KycKind? kind;
}
