import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rental_mgr_mobile/core/payments/payment_method_config.dart';

class PaymentMethodIcon extends StatelessWidget {
  const PaymentMethodIcon({
    super.key,
    required this.method,
    this.size = 36,
    this.borderRadius = 8,
  });

  final AppPaymentMethod method;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SvgPicture.asset(
        method.logoPath,
        width: size,
        height: size,
        semanticsLabel: method.label,
      ),
    );
  }
}

class PaymentMethodIconFromApi extends StatelessWidget {
  const PaymentMethodIconFromApi({
    super.key,
    required this.apiValue,
    this.size = 28,
  });

  final String? apiValue;
  final double size;

  @override
  Widget build(BuildContext context) {
    final method = AppPaymentMethod.fromApi(apiValue) ?? AppPaymentMethod.mtnMomo;
    return PaymentMethodIcon(method: method, size: size, borderRadius: 6);
  }
}
