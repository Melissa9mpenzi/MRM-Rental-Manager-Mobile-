import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/auth/kyc_draft_provider.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_flow_stepper.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

/// Step 8 — Review your details before admin review (landlord / agent).
class ReviewDetailsScreen extends ConsumerWidget {
  const ReviewDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final draft = ref.watch(kycDraftProvider);
    final loading = ref.watch(authProvider).isLoading;
    final roleLabel = draft.roleLabel == 'agent' ? 'Agent' : 'Landlord';

    return AuthPageScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthFlowStepper(step: 8),
            const SizedBox(height: 20),
            Text('Review your details', style: AppTextStyles.displayHero.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              'Confirm your profile and documents. After submit, an admin will verify your account.',
              style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
            ),
            const SizedBox(height: 20),
            GlassPanel(
              child: Column(
                children: [
                  _row('Full name', user?.fullName ?? '—'),
                  _row('Email', user?.email ?? '—'),
                  _row('Phone', user?.phone ?? '—'),
                  _row('Role', roleLabel),
                  const Divider(height: 24),
                  _row('ID front', draft.idFront != null ? 'Uploaded' : 'Missing', ok: draft.idFront != null),
                  _row('ID back / license', draft.idBack != null ? 'Uploaded' : 'Missing', ok: draft.idBack != null),
                  _row('Selfie', draft.selfie != null ? 'Uploaded' : 'Missing', ok: draft.selfie != null),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading || !draft.readyForApi
                    ? null
                    : () async {
                        try {
                          final idFront = await MultipartFile.fromFile(draft.idFront!.path, filename: 'id_front.jpg');
                          final idBack = await MultipartFile.fromFile(draft.idBack!.path, filename: 'id_back.jpg');
                          final selfie = await MultipartFile.fromFile(draft.selfie!.path, filename: 'selfie.jpg');
                          await ref.read(authProvider.notifier).submitKyc(
                                idFront: idFront,
                                idBack: idBack,
                                selfie: selfie,
                                needsDocs: true,
                              );
                          if (context.mounted) context.go(RouteNames.pendingApproval);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                            );
                          }
                        }
                      },
                child: loading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit for review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool? ok}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.captionOnDark)),
          if (ok != null)
            Icon(ok ? Icons.check_circle_outline : Icons.error_outline, size: 18, color: ok ? AppColors.accentGreen : AppColors.error),
          if (ok != null) const SizedBox(width: 6),
          Flexible(child: Text(value, style: AppTextStyles.bodyMediumOnDark, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
