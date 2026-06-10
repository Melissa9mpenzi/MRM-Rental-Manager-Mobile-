import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/tenant_api.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/utils/format_ugx.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';

final myLeaseProvider =
    FutureProvider((ref) => ref.watch(tenantApiProvider).myLease());

class TenantDashboardScreen extends ConsumerWidget {
  const TenantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final leaseAsync = ref.watch(myLeaseProvider);

    return PageScaffold(
      title: 'Dashboard',
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myLeaseProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Hi, ${user?.fullName?.split(' ').first ?? 'Tenant'} 👋',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.brandDark,
              ),
            ),
            const SizedBox(height: 24),
            leaseAsync.when(
              data: (data) {
                final lease = data['lease'];
                if (lease == null) return const Text("No active lease found.");

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RENT STATUS',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mid)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(formatUgx(lease['monthly_rent'] ?? 0),
                                  style: AppTextStyles.headingMedium.copyWith(
                                      color: const Color(0xFF0D9488))),
                              Text('Due: ${lease['end_date'] ?? 'N/A'}',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.mid)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: const Color(
                                    0xFFFFF7ED), // Very light orange
                                borderRadius: BorderRadius.circular(20)),
                            child: Text('DUE',
                                style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10)),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => context.push(RouteNames.payRent),
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accentGreen),
                          child: const Text('PAY NOW'),
                        ),
                      )
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: 32),
            const Text('QUICK ACTIONS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mid)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _QuickActionCard(
                        icon: Icons.payments_outlined,
                        label: 'Pay Rent',
                        onTap: () => context.push(RouteNames.payRent))),
                const SizedBox(width: 16),
                Expanded(
                    child: _QuickActionCard(
                        icon: Icons.report_problem_outlined,
                        label: 'Report Issue',
                        onTap: () => context.push(RouteNames.reportIssue))),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accentGreen, size: 30),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
