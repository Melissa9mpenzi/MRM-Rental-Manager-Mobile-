import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

/// Spec: verification failed — re-upload documents.
class KycRejectedScreen extends StatelessWidget {
  const KycRejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
                const SizedBox(height: 20),
                Text('Verification failed', style: AppTextStyles.headingLarge),
                const SizedBox(height: 10),
                Text(
                  'Your documents could not be approved. Please re-upload clear photos of your ID and selfie.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('${RouteNames.kyc}?role=landlord'),
                    child: const Text('Re-upload documents'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
