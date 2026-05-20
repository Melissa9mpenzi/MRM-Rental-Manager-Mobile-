import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/auth/onboarding_navigation.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_flow_stepper.dart';
import 'package:rental_mgr_mobile/core/widgets/auth_page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';

class SelectRoleScreen extends ConsumerStatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  ConsumerState<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends ConsumerState<SelectRoleScreen> {
  String? _selected;

  static const _roles = [
    _Role(
      id: 'tenant',
      title: 'Tenant',
      subtitle: 'Browse listings, apply, pay rent, and message landlords.',
      icon: Icons.search_rounded,
    ),
    _Role(
      id: 'landlord',
      title: 'Landlord',
      subtitle: 'List properties, manage leases, and track income.',
      icon: Icons.apartment_rounded,
    ),
    _Role(
      id: 'agent',
      title: 'Agent',
      subtitle: 'Upload ID, agency license, and selfie — admin approval required.',
      icon: Icons.groups_2_outlined,
    ),
  ];

  Future<void> _continue() async {
    if (_selected == null) return;
    try {
      final user = await ref.read(authProvider.notifier).updateRole(_selected!);
      if (!mounted) return;
      context.go(destinationAfterRoleSelection(_selected!));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
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
            const AuthFlowStepper(step: 5),
            const SizedBox(height: 20),
            Text('Select your role', style: AppTextStyles.displayHero.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              'Tenant gets instant access. Landlord and agent require document review by an admin.',
              style: AppTextStyles.bodyMediumOnDark.copyWith(color: AppColors.textMutedOnDark),
            ),
            const SizedBox(height: 22),
            ..._roles.map((r) {
              final on = _selected == r.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => setState(() => _selected = r.id),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 18,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: on
                                  ? AppColors.accentGreen.withOpacity(0.2)
                                  : AppColors.glassFill,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: on ? AppColors.accentGreen : AppColors.glassBorder,
                              ),
                            ),
                            child: Icon(
                              r.icon,
                              color: on ? AppColors.accentGreen : AppColors.textMutedOnDark,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.title, style: AppTextStyles.headingMedium),
                                const SizedBox(height: 4),
                                Text(r.subtitle, style: AppTextStyles.bodySmallOnDark),
                              ],
                            ),
                          ),
                          Icon(
                            on ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: on ? AppColors.accentGreen : AppColors.textMutedOnDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected == null || loading ? null : _continue,
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Role {
  const _Role({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
