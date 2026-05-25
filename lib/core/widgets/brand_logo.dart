import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

/// Official RentDirect UG logo from brand assets.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.height = 88,
    this.showTagline = false,
    this.maxWidth,
  });

  final double height;
  final bool showTagline;
  final double? maxWidth;

  static const String _asset = 'assets/images/rentdirect-logo.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          _asset,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        if (showTagline) ...[
          const SizedBox(height: 12),
          Text(
            'Secure rentals · Smart payments · Trusted by Uganda',
            style: AppTextStyles.bodyMediumOnDark.copyWith(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
