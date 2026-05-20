import 'package:flutter/material.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';

/// Dark gradient background used across auth / onboarding.
class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.body,
    this.bottom,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final Widget? bottom;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.canvasDark,
              Color(0xFF0D1518),
              Color(0xFF0A1210),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: body),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }
}
