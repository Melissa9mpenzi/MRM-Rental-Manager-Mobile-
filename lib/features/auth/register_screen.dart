import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/api_error.dart';
import 'package:rental_mgr_mobile/core/config/api_config.dart';
import 'package:rental_mgr_mobile/core/config/api_url_store.dart';
import 'package:rental_mgr_mobile/features/auth/server_settings_sheet.dart';
import 'package:rental_mgr_mobile/core/auth/auth_flow_prefs.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/constants/app_assets.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_flow_stepper.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_hero_image.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_password_field.dart';
import 'package:rental_mgr_mobile/core/widgets/social_sign_in_buttons.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agree = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agree) {
      _snack('Please accept Terms & Conditions');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      final email = _email.text.trim();
      final res = await ref.read(authProvider.notifier).register(
            fullName: _name.text.trim(),
            email: email,
            phone: _phone.text.trim(),
            password: _password.text,
          );
      if (!mounted) return;
      final devOtp = res['dev_verification_otp'];
      if (devOtp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dev verification code: $devOtp')),
        );
      }
      await AuthFlowPrefs.setSignupStep(step: AuthFlowPrefs.stepVerify, email: email);
      context.go('${RouteNames.verifyPhone}?email=${Uri.encodeComponent(email)}');
    } catch (e) {
      final base = ref.read(apiUrlProvider);
      var msg = apiErrorMessage(e, 'Registration failed.');
      if (ApiConfig.isInvalidHost(base)) msg = ApiConfig.misconfigurationHint(base);
      _snack(msg);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).isLoading;

    return AuthPageScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(RouteNames.onboarding),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textOnDark,
                  ),
                ],
              ),
              const AuthFlowStepper(step: 3),
              const SizedBox(height: 12),
              const AuthHeroImage(assetPath: AppAssets.heroVilla, height: 140),
              const SizedBox(height: 16),
              Text('Create account', style: AppTextStyles.displayHero.copyWith(fontSize: 26)),
              const SizedBox(height: 8),
              Text(
                'Uses the same API as the web app. You will verify your email next.',
                style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
              ),
              TextButton(
                onPressed: () => showServerSettingsSheet(context, ref),
                child: Text(
                  'Server settings (API connection)',
                  style: AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.accentGreen),
                ),
              ),
              const SizedBox(height: 12),
              GlassPanel(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      style: AppTextStyles.bodyMediumOnDark,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
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
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      style: AppTextStyles.bodyMediumOnDark,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_iphone_rounded),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().length < 9) ? 'Enter a valid phone' : null,
                    ),
                    const SizedBox(height: 14),
                    AuthPasswordField(
                      controller: _password,
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'Min. 6 characters' : null,
                    ),
                    const SizedBox(height: 14),
                    AuthPasswordField(
                      controller: _confirm,
                      labelText: 'Confirm password',
                      validator: (v) =>
                          v != _password.text ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text.rich(
                        TextSpan(
                          style: AppTextStyles.bodySmallOnDark,
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: AppTextStyles.bodySmallOnDark.copyWith(
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                            : const Text('Register'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.glassBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or continue with', style: AppTextStyles.captionOnDark),
                  ),
                  Expanded(child: Divider(color: AppColors.glassBorder)),
                ],
              ),
              const SizedBox(height: 12),
              const SocialSignInButtons(onboarding: true),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(RouteNames.login),
                child: Text(
                  'Already have an account? Sign in',
                  style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.accentGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
