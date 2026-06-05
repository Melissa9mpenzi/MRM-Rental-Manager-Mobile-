import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/utils/format_ugx.dart';
import 'package:rental_mgr_mobile/core/widgets/brand_logo.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

/// Branded handoff before Pesapal hosted checkout (web parity).
class PaymentCheckoutHandoffScreen extends StatefulWidget {
  const PaymentCheckoutHandoffScreen({
    super.key,
    required this.paymentLink,
    required this.amount,
    this.invoiceLabel,
    this.countdownSec = 3,
  });

  final String paymentLink;
  final num amount;
  final String? invoiceLabel;
  final int countdownSec;

  @override
  State<PaymentCheckoutHandoffScreen> createState() => _PaymentCheckoutHandoffScreenState();
}

class _PaymentCheckoutHandoffScreenState extends State<PaymentCheckoutHandoffScreen> {
  late int _seconds;
  Timer? _timer;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    _seconds = widget.countdownSec;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds <= 1) {
        _timer?.cancel();
        setState(() => _seconds = 0);
        _redirect();
      } else {
        setState(() => _seconds -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _redirect() {
    if (_redirected || !mounted) return;
    _redirected = true;
    Navigator.pop(context, widget.paymentLink);
  }

  @override
  Widget build(BuildContext context) {
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
                'SECURE CHECKOUT',
                style: AppTextStyles.captionOnDark.copyWith(
                  color: AppColors.forestTeal,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Redirecting to payment…',
                style: AppTextStyles.headingSmallOnDark,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "You'll complete MTN, Airtel, or card payment on Pesapal's secure page. "
                'We record your rent when the provider confirms.',
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
              const SizedBox(height: 28),
              const CircularProgressIndicator(color: AppColors.forestTeal),
              const SizedBox(height: 12),
              Text(
                _seconds > 0 ? 'Opening in ${_seconds}s…' : 'Opening secure payment…',
                style: AppTextStyles.captionOnDark,
              ),
              const SizedBox(height: 20),
              GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 16, color: Colors.white.withOpacity(0.45)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Powered by Pesapal · Uganda\'s trusted payment network',
                        style: AppTextStyles.captionOnDark.copyWith(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _redirect,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Pay now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
