import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/auth/firebase_google_sign_in.dart';
import 'package:rental_mgr_mobile/core/widgets/brand_sign_in_icons.dart';
import 'package:rental_mgr_mobile/core/widgets/social_sign_in_help_dialog.dart';

/// Google + Apple row shared by login and register.
class SocialSignInButtons extends ConsumerWidget {
  const SocialSignInButtons({
    super.key,
    required this.onboarding,
  });

  final bool onboarding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(authProvider).isLoading;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: loading
                ? null
                : () => signInWithGoogleAndRentDirectApi(
                      ref,
                      context,
                      onboarding: onboarding,
                    ),
            icon: const GoogleBrandIcon(size: 20),
            label: const Text('Google'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => showSocialSignInHelpDialog(context, provider: 'Apple'),
            icon: const AppleBrandIcon(size: 20),
            label: const Text('Apple'),
          ),
        ),
      ],
    );
  }
}
