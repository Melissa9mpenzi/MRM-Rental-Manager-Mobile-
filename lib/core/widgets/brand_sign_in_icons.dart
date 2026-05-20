import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class BrandSignInAssets {
  static const String google = 'assets/icons/google.svg';
  static const String apple = 'assets/icons/apple.svg';
}

/// Multicolor Google “G” mark (brand guidelines).
class GoogleBrandIcon extends StatelessWidget {
  const GoogleBrandIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      BrandSignInAssets.google,
      width: size,
      height: size,
      semanticsLabel: 'Google',
    );
  }
}

/// Apple logo for dark auth surfaces.
class AppleBrandIcon extends StatelessWidget {
  const AppleBrandIcon({super.key, this.size = 20, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Colors.white;
    return SvgPicture.asset(
      BrandSignInAssets.apple,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      semanticsLabel: 'Apple',
    );
  }
}
