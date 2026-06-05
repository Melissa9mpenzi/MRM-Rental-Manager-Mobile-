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
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
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
            // Tip banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'For bulk operations, reports and governance, use the web console.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
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
                          accent: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatMetricCard(
                          label: 'Occupancy',
                          value: '${s['occupancy_rate'] ?? 0}%',
                          icon: Icons.pie_chart_outline_rounded,
                          accent: AppColors.primary,
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
                          subtitle:
                              '${s['occupied_units'] ?? 0}/${s['total_units'] ?? 0} units occupied',
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
                          iconBg: AppColors.warningLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue (6 months)', style: AppTextStyles.headingSmall),
                        const SizedBox(height: 12),
                        _monthlyIncomeChart(s),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (_, __) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                ),
                child: Text(
                  'Sign in as a landlord and start the API to load analytics.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
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
                    Text('Top arrears', style: AppTextStyles.headingSmall),
                    const SizedBox(height: 10),
                    ...arrears.map((raw) {
                      final a = raw as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassPanel(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 12,
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.person_outline_rounded,
                                    color: AppColors.warning, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${a['full_name'] ?? 'Tenant'}',
                                        style: AppTextStyles.bodySmall
                                            .copyWith(fontWeight: FontWeight.w600)),
                                    Text(
                                        'Balance ${formatUgx(_num(a['balance_due']))}',
                                        style: AppTextStyles.caption),
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
            Text('Recent properties', style: AppTextStyles.headingSmall),
            const SizedBox(height: 10),
            stats.when(
              data: (s) {
                final recent = (s['recent_properties'] as List?) ?? [];
                if (recent.isEmpty) {
                  return GlassPanel(
                    child: Text('No properties yet.', style: AppTextStyles.bodySmall),
                  );
                }
                return Column(
                  children: recent.map((p) {
                    final m = p as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 12,
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.home_work_outlined,
                                  color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${m['name']}',
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(fontWeight: FontWeight.w600)),
                                  Text(
                                      '${m['occupied_units']}/${m['total_units']} units',
                                      style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: AppColors.textMuted, size: 18),
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
            Text('Quick actions', style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.4,
              children: [
                QuickActionChip(
                    icon: Icons.apartment_outlined,
                    label: 'Properties',
                    onTap: () => context.push(RouteNames.landlordProperties)),
                QuickActionChip(
                    icon: Icons.build_outlined,
                    label: 'Maintenance',
                    onTap: () => context.push(RouteNames.maintenance)),
                QuickActionChip(
                    icon: Icons.payments_outlined,
                    label: 'Wallet',
                    onTap: () => context.push(RouteNames.wallet)),
                QuickActionChip(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Rental Hub',
                    onTap: () => context.push(RouteNames.messages)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _monthlyIncomeChart(Map<String, dynamic> s) {
    final rows = (s['monthly_income'] as List?) ?? [];
    if (rows.isEmpty) {
      return Text('No revenue history yet.', style: AppTextStyles.caption);
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
