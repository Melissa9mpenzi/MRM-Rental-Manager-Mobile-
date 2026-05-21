import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/api_error.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_password_field.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/otp_input_row.dart';

/// Same flow as web: step 1 send email code → step 2 enter OTP + new password.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.initialEmail,
    this.initialStep = 1,
  });

  final String? initialEmail;
  final int initialStep;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late int _step;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep.clamp(1, 2);
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _email.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email')),
      );
      return;
    }
    try {
      final res = await ref.read(authProvider.notifier).forgotPassword(email);
      if (!mounted) return;
      final devOtp = res['dev_reset_otp'];
      if (devOtp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dev mode: use code $devOtp (also in API terminal).'),
            duration: const Duration(seconds: 12),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset code sent! Check your inbox and spam folder.'),
          ),
        );
      }
      setState(() => _step = 2);
      final em = Uri.encodeComponent(email);
      context.go('${RouteNames.forgotPassword}?email=$em&step=2');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    }
  }

  Future<void> _resendCode() async {
    try {
      final res = await ref.read(authProvider.notifier).forgotPassword(_email.text.trim());
      if (!mounted) return;
      final devOtp = res['dev_reset_otp'];
      if (devOtp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dev reset code: $devOtp')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New code sent if the email exists.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code')),
      );
      return;
    }
    if (_password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password min. 6 characters')),
      );
      return;
    }
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    try {
      await ref.read(authProvider.notifier).resetPassword(
            email: _email.text.trim(),
            otp: _otp,
            newPassword: _password.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset! You can now sign in.')),
      );
      final em = Uri.encodeComponent(_email.text.trim());
      context.go('${RouteNames.login}?email=$em');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).isLoading;

    return AuthPageScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_step == 2) {
                      setState(() => _step = 1);
                      context.go(RouteNames.forgotPassword);
                    } else {
                      context.go(RouteNames.login);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: AppColors.textOnDark,
                ),
              ],
            ),
            _StepIndicator(current: _step),
            const SizedBox(height: 16),
            if (_step == 1) ...[
              Text('Forgot password?', style: AppTextStyles.displayHero.copyWith(fontSize: 26)),
              const SizedBox(height: 8),
              Text(
                'We will email a 6-digit reset code (same as the web app).',
                style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
              ),
              const SizedBox(height: 24),
              GlassPanel(
                child: Column(
                  children: [
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyMediumOnDark,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : _sendCode,
                        child: loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Send reset code'),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text('Check your email', style: AppTextStyles.displayHero.copyWith(fontSize: 26)),
              const SizedBox(height: 8),
              Text(
                '6-digit code sent to ${_email.text.trim()}',
                style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
              ),
              const SizedBox(height: 24),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OtpInputRow(onCompleted: (c) => setState(() => _otp = c)),
                    const SizedBox(height: 20),
                    AuthPasswordField(
                      controller: _password,
                      labelText: 'New password',
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading || _otp.length < 6 ? null : _resetPassword,
                        child: loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Reset password'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: loading ? null : _resendCode,
                      child: Text(
                        'Resend code',
                        style: AppTextStyles.bodySmallOnDark.copyWith(color: AppColors.accentGreen),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(1, 'Email'),
        Expanded(child: Container(height: 1, color: AppColors.glassBorder)),
        _dot(2, 'Reset'),
      ],
    );
  }

  Widget _dot(int n, String label) {
    final active = current >= n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: active ? AppColors.accentGreen : AppColors.glassBorder,
            child: Text(
              '$n',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: active ? AppColors.deepCharcoal : AppColors.textMutedOnDark,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.captionOnDark.copyWith(
              color: current == n ? AppColors.textOnDark : AppColors.textMutedOnDark,
              fontWeight: current == n ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
