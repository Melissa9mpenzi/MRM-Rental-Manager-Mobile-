import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/dashboard_api.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final _landlordStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(dashboardApiProvider).stats();
});

class LandlordDashboardScreen extends ConsumerWidget {
  const LandlordDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(_landlordStatsProvider);

    return PageScaffold(
      title: 'Landlord overview',
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        onRefresh: () async => ref.invalidate(_landlordStatsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            stats.when(
              data: (s) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatMetricCard(
                          label: 'Total revenue (month)',
                          value: 'UGX ${s['this_month_collected'] ?? 0}',
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatMetricCard(
                          label: 'Occupancy',
                          value: '${s['occupancy_rate'] ?? 0}%',
                          icon: Icons.pie_chart_outline_rounded,
                          accent: AppColors.forestTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: StatMetricCard(
                          label: 'Properties',
                          value: '${s['total_properties'] ?? 0}',
                          icon: Icons.apartment_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatMetricCard(
                          label: 'Arrears',
                          value: 'UGX ${s['total_arrears'] ?? 0}',
                          icon: Icons.warning_amber_rounded,
                          accent: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
              error: (_, __) => GlassPanel(
                child: Text('Start backend to load landlord analytics.', style: AppTextStyles.captionOnDark),
              ),
            ),
            const SizedBox(height: 20),
            Text('Recent properties', style: AppTextStyles.headingMedium),
            const SizedBox(height: 10),
            stats.when(
              data: (s) {
                final recent = (s['recent_properties'] as List?) ?? [];
                if (recent.isEmpty) {
                  return GlassPanel(child: Text('No properties yet.', style: AppTextStyles.bodySmallOnDark));
                }
                return Column(
                  children: recent.map((p) {
                    final m = p as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 14,
                        child: Row(
                          children: [
                            const Icon(Icons.home_work_outlined, color: AppColors.accentGreen),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${m['name']}', style: AppTextStyles.bodyMediumOnDark),
                                  Text('${m['occupied_units']}/${m['total_units']} units', style: AppTextStyles.captionOnDark),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.4,
              children: [
                QuickActionChip(icon: Icons.apartment_outlined, label: 'Properties', onTap: () => context.push(RouteNames.landlordProperties)),
                QuickActionChip(icon: Icons.build_outlined, label: 'Maintenance', onTap: () => context.push(RouteNames.maintenance)),
                QuickActionChip(icon: Icons.payments_outlined, label: 'Payments', onTap: () => context.push(RouteNames.wallet)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
