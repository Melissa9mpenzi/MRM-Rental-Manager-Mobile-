import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/api_error.dart';
import 'package:rental_mgr_mobile/core/auth/auth_navigation.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/config/api_config.dart';
import 'package:rental_mgr_mobile/core/config/api_url_store.dart';
import 'package:rental_mgr_mobile/features/auth/server_settings_sheet.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/brand_logo.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_password_field.dart';
import 'package:rental_mgr_mobile/core/widgets/social_sign_in_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialEmail, this.onboarding = false});

  final String? initialEmail;
  final bool onboarding;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _email;
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    try {
      final user = await ref.read(authProvider.notifier).login(
            email: _email.text.trim(),
            password: _password.text,
          );
      if (!mounted) return;
      await navigateAfterLogin(
        ref,
        context,
        user: user,
        onboardingLogin: widget.onboarding,
      );
    } catch (e) {
      if (!mounted) return;
      final base = ref.read(apiUrlProvider);
      var msg = apiErrorMessage(e, 'Sign-in failed.');
      if (ApiConfig.isInvalidHost(base)) msg = ApiConfig.misconfigurationHint(base);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 8)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).isLoading;

    return AuthPageScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: BrandLogo(height: 56)),
              const SizedBox(height: 16),
              if (widget.onboarding)
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        final em = Uri.encodeComponent(_email.text.trim());
                        context.go('${RouteNames.verifyPhone}?email=$em');
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppColors.textOnDark,
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Text(
                widget.onboarding ? 'Sign in to continue' : 'Welcome back',
                style: AppTextStyles.displayHero.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in with the same account as the web app.',
                style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
              ),
              Builder(
                builder: (context) {
                  final apiBase = ref.watch(apiUrlProvider);
                  final invalid = ApiConfig.isInvalidHost(apiBase);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        'API: $apiBase',
                        style: AppTextStyles.captionOnDark.copyWith(color: AppColors.textMutedOnDark),
                      ),
                      TextButton(
                        onPressed: () => showServerSettingsSheet(context, ref),
                        child: Text(
                          'Server settings (fix connection)',
                          style: AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.accentGreen),
                        ),
                      ),
                      if (invalid)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Text(
                            ApiConfig.misconfigurationHint(apiBase),
                            style: AppTextStyles.bodySmallOnDark.copyWith(color: Colors.orange.shade100),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyMediumOnDark,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthPasswordField(
                      controller: _password,
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'Min. 6 characters' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : _submit,
                        child: loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Sign in'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.glassBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or continue with', style: AppTextStyles.captionOnDark),
                  ),
                  const Expanded(child: Divider(color: AppColors.glassBorder)),
                ],
              ),
              const SizedBox(height: 12),
              SocialSignInButtons(onboarding: widget.onboarding),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(RouteNames.forgotPassword),
                  child: Text(
                    'Forgot password?',
                    style: AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.accentGreen),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(RouteNames.register),
                child: Text.rich(
                  TextSpan(
                    text: "New here? ",
                    style: AppTextStyles.bodyMediumOnDark.copyWith(
                      color: AppColors.textMutedOnDark,
                    ),
                    children: [
                      TextSpan(
                        text: 'Create an account',
                        style: AppTextStyles.bodyMediumOnDark.copyWith(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
