import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';

/// Hex-style logo from the design board.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 88, this.showTagline = false});

  final double size;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(size: Size(size, size), painter: _HexLogoPainter()),
        const SizedBox(height: 16),
        Text('RentDirect UG', style: AppTextStyles.displayHero.copyWith(fontSize: size * 0.32)),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            'Find. Rent. Pay. All in One Place.',
            style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _HexLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * math.pi / 180;
      final p = Offset(center.dx + r * 0.92 * math.cos(angle), center.dy + r * 0.92 * math.sin(angle));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.accentGreen, Color(0xFF059669)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    final icon = Icons.home_rounded;
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: r * 0.5,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
