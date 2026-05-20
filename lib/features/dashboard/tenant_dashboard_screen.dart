import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_mgr_mobile/core/api/marketplace_api.dart';
import 'package:rental_mgr_mobile/core/api/tenant_api.dart';
import 'package:rental_mgr_mobile/core/auth/auth_provider.dart';
import 'package:rental_mgr_mobile/core/routing/route_names.dart';
import 'package:rental_mgr_mobile/core/theme/app_colors.dart';
import 'package:rental_mgr_mobile/core/theme/app_text_styles.dart';
import 'package:rental_mgr_mobile/core/utils/format_ugx.dart';
import 'package:rental_mgr_mobile/core/utils/media_url.dart';
import 'package:rental_mgr_mobile/core/widgets/dashboard_greeting.dart';
import 'package:rental_mgr_mobile/core/widgets/glass_panel.dart';
import 'package:rental_mgr_mobile/core/widgets/page_scaffold.dart';
import 'package:rental_mgr_mobile/core/widgets/payment_method_icon.dart';

final _recommendedProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(marketplaceApiProvider).listings(search: '');
});

final _tenantPaymentsPreviewProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    return await ref.read(tenantApiProvider).myPayments();
  } catch (_) {
    return <dynamic>[];
  }
});

class TenantDashboardScreen extends ConsumerWidget {
  const TenantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(_recommendedProvider);
    final payments = ref.watch(_tenantPaymentsPreviewProvider);
    final user = ref.watch(authProvider).user;

    return PageScaffold(
      title: 'Home',
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        onRefresh: () async {
          ref.invalidate(_recommendedProvider);
          ref.invalidate(_tenantPaymentsPreviewProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (user != null)
              DashboardGreeting(
                fullName: user.fullName,
                subtitle: 'Find. Rent. Pay. All in one place.',
              ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              onTap: () => context.push(RouteNames.search),
              decoration: InputDecoration(
                hintText: 'Search city, price, bedrooms…',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accentGreen),
                filled: true,
                fillColor: AppColors.glassFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Recommended for you', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),
            listings.when(
              data: (list) {
                if (list.isEmpty) {
                  return Text('No listings yet. Pull to refresh.', style: AppTextStyles.captionOnDark);
                }
                return SizedBox(
                  height: 168,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length.clamp(0, 8),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final m = list[i] as Map<String, dynamic>;
                      final id = (m['id'] as num).toInt();
                      final img = resolveMediaUrl(m['image'] as String?);
                      return GestureDetector(
                        onTap: () => context.push(RouteNames.listingDetail(id)),
                        child: SizedBox(
                          width: 200,
                          child: GlassPanel(
                            padding: EdgeInsets.zero,
                            borderRadius: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    child: img.isNotEmpty
                                        ? Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imgPlaceholder())
                                        : _imgPlaceholder(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${m['title'] ?? 'Listing'}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodySmallOnDark.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        '${formatUgx(_num(m['price']))} / mo · ${m['loc'] ?? ''}',
                                        style: AppTextStyles.captionOnDark,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              error: (_, __) => Text('Connect backend to load listings.', style: AppTextStyles.captionOnDark),
            ),
            const SizedBox(height: 24),
            Text('Quick actions', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                QuickActionChip(icon: Icons.payments_outlined, label: 'Pay rent', onTap: () => context.push(RouteNames.payRent)),
                QuickActionChip(icon: Icons.description_outlined, label: 'My contracts', onTap: () => context.push(RouteNames.contracts)),
                QuickActionChip(icon: Icons.account_balance_wallet_outlined, label: 'Wallet', onTap: () => context.push(RouteNames.wallet)),
                QuickActionChip(icon: Icons.chat_bubble_outline_rounded, label: 'Messages', onTap: () => context.push(RouteNames.messages)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Recent activity', style: AppTextStyles.headingMedium),
            const SizedBox(height: 10),
            payments.when(
              data: (list) {
                if (list.isEmpty) {
                  return GlassPanel(
                    child: Text(
                      'No payments yet. When you pay rent, it will show here.',
                      style: AppTextStyles.captionOnDark,
                    ),
                  );
                }
                final slice = list.take(5).toList();
                return Column(
                  children: slice.map((raw) {
                    final p = raw as Map<String, dynamic>;
                    final amt = _num(p['amount']);
                    final date = p['payment_date'] as String? ?? p['created_at'] as String? ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        borderRadius: 14,
                        child: Row(
                          children: [
                            PaymentMethodIconFromApi(apiValue: p['payment_method'] as String?, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payment · ${formatUgx(amt)}', style: AppTextStyles.bodySmallOnDark),
                                  if (date.isNotEmpty)
                                    Text(date.length > 10 ? date.substring(0, 10) : date, style: AppTextStyles.captionOnDark),
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
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(color: AppColors.accentGreen, strokeWidth: 2)),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(color: AppColors.surfaceDark, child: const Icon(Icons.home_work_outlined, color: AppColors.textMutedOnDark, size: 40));
}

num _num(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}
