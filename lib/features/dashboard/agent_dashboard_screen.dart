import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/workspace_api.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final _staffSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(workspaceApiProvider).staffSummary();
});

class AgentDashboardScreen extends ConsumerWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(_staffSummaryProvider);

    return PageScaffold(
      title: 'Agency workspace',
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        onRefresh: () async => ref.invalidate(_staffSummaryProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            summary.when(
              data: (s) {
                final kpis = s['kpis'] as Map<String, dynamic>? ?? {};
                return Row(
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
                        label: 'Active deals',
                        value: '${kpis['active_deals'] ?? 0}',
                        icon: Icons.handshake_outlined,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
              error: (_, __) => GlassPanel(child: Text('Agent metrics from /workspace/staff/summary', style: AppTextStyles.captionOnDark)),
            ),
            const SizedBox(height: 20),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Leads pipeline', style: AppTextStyles.headingMedium),
                  const SizedBox(height: 12),
                  _bar('New', 0.35),
                  _bar('Contacted', 0.28),
                  _bar('Viewing', 0.22),
                  _bar('Negotiation', 0.15),
                ],
              ),
            ),
            const SizedBox(height: 16),
            QuickActionChip(
              icon: Icons.search_rounded,
              label: 'Browse listings',
              onTap: () => context.push(RouteNames.search),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(String label, double v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.captionOnDark),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: AppColors.glassFill, color: AppColors.accentGreen),
            ),
          ],
        ),
      );
}
