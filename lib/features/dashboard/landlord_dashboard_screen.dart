import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/providers/dashboard_providers.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/utils/format_ugx.dart';
import 'package:rental_mgr_mobile/core/widgets/dashboard_charts.dart';
import 'package:rental_mgr_mobile/core/widgets/dashboard_greeting.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

class LandlordDashboardScreen extends ConsumerWidget {
  const LandlordDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(landlordDashboardStatsProvider);
    final user = ref.watch(authProvider).user;

    return PageScaffold(
      title: 'Overview',
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        onRefresh: () async => ref.invalidate(landlordDashboardStatsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (user != null)
              DashboardGreeting(
                fullName: user.fullName,
                subtitle: 'Portfolio performance at a glance.',
              ),
            const SizedBox(height: 16),
            GlassPanel(
              padding: const EdgeInsets.all(12),
              borderRadius: 14,
              child: Text(
                'Mobile is optimized for quick landlord actions. For bulk operations, deep analytics, reports, and governance workflows, use the web console.',
                style: AppTextStyles.captionOnDark,
              ),
            ),
            const SizedBox(height: 12),
            stats.when(
              data: (s) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatMetricCard(
                          label: 'Collected this month',
                          value: formatUgx(_num(s['this_month_collected'])),
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
                          subtitle: '${s['occupied_units'] ?? 0}/${s['total_units'] ?? 0} units occupied',
                          icon: Icons.apartment_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatMetricCard(
                          label: 'Arrears',
                          value: formatUgx(_num(s['total_arrears'])),
                          subtitle: '${s['tenants_in_arrears'] ?? 0} tenants',
                          icon: Icons.warning_amber_rounded,
                          accent: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue (6 months)', style: AppTextStyles.headingSmallOnDark),
                        const SizedBox(height: 12),
                        _monthlyIncomeChart(s),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.accentGreen))),
              error: (_, __) => GlassPanel(
                child: Text('Sign in as a landlord and start the API to load analytics.', style: AppTextStyles.captionOnDark),
              ),
            ),
            const SizedBox(height: 20),
            stats.when(
              data: (s) {
                final arrears = (s['top_arrears'] as List?) ?? [];
                if (arrears.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top arrears', style: AppTextStyles.headingMedium),
                    const SizedBox(height: 10),
                    ...arrears.map((raw) {
                      final a = raw as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassPanel(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 14,
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, color: AppColors.warning, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${a['full_name'] ?? 'Tenant'}', style: AppTextStyles.bodySmallOnDark),
                                    Text('Balance ${formatUgx(_num(a['balance_due']))}', style: AppTextStyles.captionOnDark),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
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
            Text('Quick actions', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),
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
                QuickActionChip(icon: Icons.payments_outlined, label: 'Wallet', onTap: () => context.push(RouteNames.wallet)),
                QuickActionChip(icon: Icons.chat_bubble_outline_rounded, label: 'Rental Hub', onTap: () => context.push(RouteNames.messages)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthlyIncomeChart(Map<String, dynamic> s) {
    final rows = (s['monthly_income'] as List?) ?? [];
    if (rows.isEmpty) {
      return Text('No revenue history yet.', style: AppTextStyles.captionOnDark);
    }
    final labels = <String>[];
    final values = <double>[];
    for (final raw in rows) {
      final m = raw as Map<String, dynamic>;
      labels.add('${m['month'] ?? ''}');
      values.add(_num(m['collected']).toDouble());
    }
    return DashboardBarChart(labels: labels, values: values);
  }
}

num _num(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}
