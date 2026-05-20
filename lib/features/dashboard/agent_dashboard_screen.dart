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

class AgentDashboardScreen extends ConsumerWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(agentWorkspaceSummaryProvider);
    final user = ref.watch(authProvider).user;

    return PageScaffold(
      title: 'Workspace',
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        onRefresh: () async => ref.invalidate(agentWorkspaceSummaryProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (user != null)
              DashboardGreeting(
                fullName: user.fullName,
                subtitle: 'Leads, listings, and maintenance in one view.',
              ),
            const SizedBox(height: 16),
            summary.when(
              data: (s) {
                final kpis = s['kpis'] as Map<String, dynamic>? ?? {};
                final maint = s['maintenance'] as Map<String, dynamic>? ?? {};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatMetricCard(
                            label: 'Total leads',
                            value: '${kpis['total_leads'] ?? 0}',
                            icon: Icons.people_outline,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatMetricCard(
                            label: 'Active tickets',
                            value: '${maint['open'] ?? 0} open · ${maint['in_progress'] ?? 0} in progress',
                            icon: Icons.handshake_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: StatMetricCard(
                            label: 'Listings live',
                            value: '${s['properties_listed'] ?? 0}',
                            icon: Icons.list_alt_outlined,
                            accent: AppColors.forestTeal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatMetricCard(
                            label: 'Commissions YTD',
                            value: formatUgx(_num(kpis['commissions_ytd_ugx'])),
                            subtitle: 'Pending ${formatUgx(_num(kpis['pending_payout_ugx']))}',
                            icon: Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
              error: (_, __) => GlassPanel(
                child: Text(
                  'Agent metrics use GET /workspace/staff/summary (staff or admin token).',
                  style: AppTextStyles.captionOnDark,
                ),
              ),
            ),
            const SizedBox(height: 18),
            summary.when(
              data: (s) => GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pipeline', style: AppTextStyles.headingSmallOnDark),
                    const SizedBox(height: 12),
                    ..._pipelineBars(s),
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            summary.when(
              data: (s) {
                final trend = (s['commission_trend'] as List?) ?? [];
                if (trend.isEmpty) return const SizedBox.shrink();
                final labels = <String>[];
                final values = <double>[];
                for (final raw in trend) {
                  final m = raw as Map<String, dynamic>;
                  labels.add('${m['m'] ?? ''}');
                  values.add(_num(m['v']).toDouble());
                }
                return GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Commission trend', style: AppTextStyles.headingSmallOnDark),
                      const SizedBox(height: 12),
                      DashboardBarChart(labels: labels, values: values, height: 100, barColor: AppColors.forestTeal),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
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
                QuickActionChip(icon: Icons.search_rounded, label: 'Browse listings', onTap: () => context.push(RouteNames.search)),
                QuickActionChip(icon: Icons.chat_bubble_outline_rounded, label: 'Messages', onTap: () => context.push(RouteNames.messages)),
                QuickActionChip(icon: Icons.build_outlined, label: 'Maintenance', onTap: () => context.push(RouteNames.maintenance)),
                QuickActionChip(icon: Icons.account_balance_wallet_outlined, label: 'Wallet', onTap: () => context.push(RouteNames.wallet)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _pipelineBars(Map<String, dynamic> s) {
    final stages = (s['pipeline_stages'] as List?) ?? [];
    if (stages.isEmpty) {
      return [
        Text('Pipeline stages will appear when CRM data is wired.', style: AppTextStyles.captionOnDark),
      ];
    }
    var maxC = 1;
    for (final raw in stages) {
      final m = raw as Map<String, dynamic>;
      final c = (m['count'] as num?)?.toInt() ?? 0;
      if (c > maxC) maxC = c;
    }
    return stages.map((raw) {
      final m = raw as Map<String, dynamic>;
      final label = '${m['stage'] ?? ''}';
      final c = (m['count'] as num?)?.toInt() ?? 0;
      final v = maxC > 0 ? c / maxC : 0.0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: AppTextStyles.captionOnDark),
                Text('$c', style: AppTextStyles.bodySmallOnDark),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: v.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.glassFill,
                color: AppColors.accentGreen,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

num _num(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}
