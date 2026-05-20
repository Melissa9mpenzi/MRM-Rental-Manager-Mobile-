import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/workspace_api.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final _adminSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(workspaceApiProvider).adminSummary();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(_adminSummaryProvider);

    return PageScaffold(
      title: 'Platform overview',
      actions: [
        IconButton(
          icon: const Icon(Icons.verified_user_outlined),
          onPressed: () => context.push(RouteNames.adminModeration),
        ),
      ],
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        onRefresh: () async => ref.invalidate(_adminSummaryProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            summary.when(
              data: (s) {
                final byRole = s['users_by_role'] as Map<String, dynamic>? ?? {};
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: StatMetricCard(label: 'Total users', value: '${s['users_total'] ?? 0}', icon: Icons.groups_outlined)),
                        const SizedBox(width: 10),
                        Expanded(child: StatMetricCard(label: 'Listings', value: '${s['properties_active'] ?? 0}', icon: Icons.apartment_outlined)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    StatMetricCard(
                      label: 'Revenue this month',
                      value: 'UGX ${s['payments_rent_this_month'] ?? 0}',
                      icon: Icons.payments_outlined,
                    ),
                    const SizedBox(height: 16),
                    GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Users by role', style: AppTextStyles.headingSmallOnDark),
                          const SizedBox(height: 8),
                          ...byRole.entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e.key, style: AppTextStyles.bodySmallOnDark),
                                  Text('${e.value}', style: AppTextStyles.bodyMediumOnDark),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
              error: (_, __) => GlassPanel(
                child: Text('Admin API requires an admin account.', style: AppTextStyles.captionOnDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
