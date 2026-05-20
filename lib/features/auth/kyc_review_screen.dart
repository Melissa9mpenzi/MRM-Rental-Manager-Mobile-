import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/kyc_draft_provider.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_flow_stepper.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

/// Step 7 — Review verification (document checklist).
class KycReviewScreen extends ConsumerWidget {
  const KycReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(kycDraftProvider);

    return AuthPageScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthFlowStepper(step: 7),
            const SizedBox(height: 20),
            Text('Review verification', style: AppTextStyles.displayHero.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              'Confirm each document is clear and readable before continuing.',
              style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _tile('ID front', draft.idFront?.name ?? 'Missing', draft.idFront != null),
                  _tile('ID back / license', draft.idBack?.name ?? 'Missing', draft.idBack != null),
                  _tile('Selfie', draft.selfie?.name ?? 'Missing', draft.selfie != null),
                  if (draft.extraLabel != null) _tile(draft.extraLabel!, 'Attached locally', true),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: draft.readyForApi ? () => context.push(RouteNames.reviewDetails) : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String title, String status, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        borderRadius: 14,
        child: Row(
          children: [
            Icon(ok ? Icons.check_circle_outline : Icons.error_outline, color: ok ? AppColors.accentGreen : AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headingSmallOnDark),
                  Text(status, style: AppTextStyles.captionOnDark, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
