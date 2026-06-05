import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/payments_api.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/utils/format_ugx.dart';
import 'package:rental_mgr_mobile/core/widgets/brand_logo.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

enum MomoProcessingResult { completed, failed, timeout, cancelled }

/// In-app MTN MoMo flow — USSD prompt, no Pesapal redirect (web parity).
class PaymentMomoProcessingScreen extends ConsumerStatefulWidget {
  const PaymentMomoProcessingScreen({
    super.key,
    required this.reference,
    required this.phone,
    required this.amount,
    this.invoiceLabel,
    this.message,
  });

  final String reference;
  final String phone;
  final num amount;
  final String? invoiceLabel;
  final String? message;

  @override
  ConsumerState<PaymentMomoProcessingScreen> createState() => _PaymentMomoProcessingScreenState();
}

class _PaymentMomoProcessingScreenState extends ConsumerState<PaymentMomoProcessingScreen> {
  String _phase = 'waiting';
  String _detail = '';

  @override
  void initState() {
    super.initState();
    _poll();
  }

  Future<void> _poll() async {
    final api = ref.read(paymentsApiProvider);
    for (var i = 0; i < 40; i++) {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      try {
        final status = await api.getCheckout(widget.reference);
        final st = '${status['status'] ?? ''}'.toLowerCase();
        if (st == 'completed') {
          if (!mounted) return;
          setState(() => _phase = 'success');
          return;
        }
        if (st == 'failed') {
          if (!mounted) return;
          setState(() {
            _phase = 'failed';
            _detail = status['failure_reason']?.toString() ?? 'Payment failed or was cancelled.';
          });
          return;
        }
      } catch (_) {
        /* keep polling */
      }
    }
    if (mounted) setState(() => _phase = 'timeout');
  }

  void _close(MomoProcessingResult result) {
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_phase) {
      'success' => 'Payment confirmed',
      'failed' => 'Payment not completed',
      'timeout' => 'Still processing',
      _ => 'Approve on your phone',
    };
    final subtitle = switch (_phase) {
      'success' => 'Your rent payment has been recorded.',
      'failed' => _detail,
      'timeout' => 'MTN may still be processing. Check Wallet in a minute.',
      _ => widget.message ??
          'Check your MTN phone and approve the MoMo prompt. Do not close this screen.',
    };

    return Scaffold(
      backgroundColor: AppColors.deepCharcoal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              const BrandLogo(height: 48),
              const SizedBox(height: 8),
              Text(
                'MTN MOBILE MONEY',
                style: AppTextStyles.captionOnDark.copyWith(
                  color: AppColors.forestTeal,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC00).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.smartphone, color: Color(0xFFFFCC00), size: 30),
              ),
              const SizedBox(height: 20),
              Text(title, style: AppTextStyles.headingSmallOnDark, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: AppTextStyles.bodyMediumOnDark.copyWith(color: Colors.white.withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GlassPanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (widget.invoiceLabel != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invoice', style: AppTextStyles.captionOnDark),
                          Text(widget.invoiceLabel!, style: AppTextStyles.bodyMediumOnDark),
                        ],
                      ),
                    if (widget.invoiceLabel != null) const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amount', style: AppTextStyles.bodyMediumOnDark.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          formatUgx(widget.amount),
                          style: AppTextStyles.bodyMediumOnDark.copyWith(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_phase == 'waiting') ...[
                const SizedBox(height: 20),
                GlassPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_outlined, size: 16, color: AppColors.forestTeal),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Prompt sent to ${widget.phone}',
                          style: AppTextStyles.captionOnDark,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: AppColors.forestTeal),
                const SizedBox(height: 10),
                Text('Waiting for MTN confirmation…', style: AppTextStyles.captionOnDark),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _close(
                    _phase == 'success'
                        ? MomoProcessingResult.completed
                        : _phase == 'failed'
                            ? MomoProcessingResult.failed
                            : _phase == 'timeout'
                                ? MomoProcessingResult.timeout
                                : MomoProcessingResult.cancelled,
                  ),
                  child: Text(_phase == 'waiting' ? 'Close (payment may still complete)' : 'Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
