import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/providers/dashboard_providers.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/utils/format_ugx.dart';
import 'package:rental_mgr_mobile/core/widgets/dashboard_charts.dart';
import 'package:rental_mgr_mobile/core/widgets/dashboard_greeting.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(adminWorkspaceSummaryProvider);
    final user = ref.watch(authProvider).user;

    return PageScaffold(
      title: 'Platform',
      actions: [
        IconButton(
          icon: const Icon(Icons.verified_user_outlined),
          tooltip: 'KYC moderation (web)',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('NIRA KYC moderation runs on the government web portal.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        onRefresh: () async => ref.invalidate(adminWorkspaceSummaryProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (user != null)
              DashboardGreeting(
                fullName: user.fullName,
                subtitle: 'RentDirect UG — platform health.',
              ),
            const SizedBox(height: 16),
            summary.when(
              data: (s) {
                final byRole = s['users_by_role'] as Map<String, dynamic>? ?? {};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatMetricCard(
                            label: 'Total users',
                            value: '${s['users_total'] ?? 0}',
                            icon: Icons.groups_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatMetricCard(
                            label: 'Active listings',
                            value: '${s['properties_active'] ?? 0}',
                            icon: Icons.apartment_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: StatMetricCard(
                            label: 'Rent volume (month)',
                            value: formatUgx(_num(s['payments_rent_this_month'])),
                            icon: Icons.payments_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatMetricCard(
                            label: 'Maintenance',
                            value: '${s['maintenance_open'] ?? 0} open',
                            subtitle: '${s['maintenance_in_progress'] ?? 0} in progress',
                            icon: Icons.build_outlined,
                            accent: AppColors.warning,
                          ),
                        ),
                      ],
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
                child: Text('Admin summary requires an admin account (GET /workspace/admin/summary).', style: AppTextStyles.captionOnDark),
              ),
            ),
            const SizedBox(height: 18),
            summary.when(
              data: (s) {
                final monthly = (s['monthly_platform'] as List?) ?? [];
                if (monthly.isEmpty) return const SizedBox.shrink();
                final labels = <String>[];
                final values = <double>[];
                for (final raw in monthly) {
                  final m = raw as Map<String, dynamic>;
                  labels.add('${m['month'] ?? ''}');
                  values.add(_num(m['payment_volume']).toDouble());
                }
                return GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment volume (6 mo)', style: AppTextStyles.headingSmallOnDark),
                      const SizedBox(height: 12),
                      DashboardBarChart(labels: labels, values: values),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 18),
            summary.when(
              data: (s) {
                final recent = (s['recent_users'] as List?) ?? [];
                if (recent.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent sign-ups', style: AppTextStyles.headingMedium),
                    const SizedBox(height: 10),
                    ...recent.take(6).map((raw) {
                      final u = raw as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassPanel(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 14,
                          child: Row(
                            children: [
                              const Icon(Icons.person_add_alt_1_outlined, color: AppColors.accentGreen, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${u['full_name'] ?? u['email']}', style: AppTextStyles.bodySmallOnDark),
                                    Text('${u['role'] ?? ''} · ${(u['created_at'] as String?)?.substring(0, 10) ?? ''}', style: AppTextStyles.captionOnDark),
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
            const SizedBox(height: 12),
            summary.when(
              data: (s) {
                final audit = (s['recent_audit'] as List?) ?? [];
                if (audit.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent audit', style: AppTextStyles.headingMedium),
                    const SizedBox(height: 10),
                    ...audit.take(5).map((raw) {
                      final a = raw as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassPanel(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 14,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.history_rounded, color: AppColors.textMutedOnDark, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${a['action'] ?? ''}', style: AppTextStyles.bodySmallOnDark),
                                    Text(
                                      '${a['table_name'] ?? ''} #${a['record_id'] ?? ''}',
                                      style: AppTextStyles.captionOnDark,
                                    ),
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
          ],
        ),
      ),
    );
  }
}

num _num(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}
